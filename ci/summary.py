"""Write a Markdown summary of a Robot Framework run.

GitHub Actions shows whatever a step appends to the file in $GITHUB_STEP_SUMMARY
on the run's page, so the result is visible without downloading the artifact.

Usage:  python ci/summary.py results/output.xml "Chrome"
Without $GITHUB_STEP_SUMMARY (e.g. locally) the Markdown is printed instead.
"""

import os
import sys

from robot.api import ExecutionResult, ResultVisitor


class FailedTests(ResultVisitor):
    """Collects (suite, test, message) for every failed test."""

    def __init__(self):
        self.failed = []

    def visit_test(self, test):
        if test.failed:
            # First line only: Robot messages can be long multi-line diffs.
            message = test.message.splitlines()[0] if test.message else ""
            self.failed.append((test.parent.name, test.name, message))


def _cell(text):
    """Escape the characters that would break a Markdown table cell."""
    return text.replace("|", "\\|").replace("\n", " ")


def build_summary(output_xml, title):
    """Return the Markdown summary for one output.xml."""
    result = ExecutionResult(output_xml)
    total = result.statistics.total
    icon = "✅" if total.failed == 0 else "❌"
    lines = [
        f"## {icon} Robot Framework: {title}",
        "",
        f"**{total.passed} passed**, **{total.failed} failed**, {total.skipped} skipped"
        f" of {total.total} tests · elapsed {str(result.suite.elapsed_time).split('.')[0]}",
        "",
        "| Suite | Passed | Failed | Skipped |",
        "|---|---:|---:|---:|",
    ]
    # One row per suite file (the leaves of the suite tree), in run order.
    for suite in _leaf_suites(result.suite):
        stats = suite.statistics
        # "Robot Framework Automation.Ui.03 Cart" -> "Ui / 03 Cart": the root name adds nothing.
        name = " / ".join(suite.full_name.split(".")[1:])
        lines.append(f"| {_cell(name)} | {stats.passed} | {stats.failed} | {stats.skipped} |")

    collector = FailedTests()
    result.visit(collector)
    if collector.failed:
        lines += ["", "### Failed tests", "", "| Suite | Test | Message |", "|---|---|---|"]
        for suite, test, message in collector.failed:
            lines.append(f"| {_cell(suite)} | {_cell(test)} | {_cell(message)} |")
    lines += ["", "Full log and report: see the *results* artifact of this run.", ""]
    return "\n".join(lines)


def _leaf_suites(suite):
    """Yield the suites that contain tests directly (one per .robot file)."""
    if suite.tests:
        yield suite
    for child in suite.suites:
        yield from _leaf_suites(child)


def main():
    if len(sys.argv) != 3:
        sys.exit("usage: python ci/summary.py <output.xml> <title>")
    markdown = build_summary(sys.argv[1], sys.argv[2])
    target = os.environ.get("GITHUB_STEP_SUMMARY")
    if target:
        with open(target, "a", encoding="utf-8") as file:
            file.write(markdown)
    else:
        # Windows consoles default to cp1252, which has no emoji.
        sys.stdout.reconfigure(encoding="utf-8")
        print(markdown)


if __name__ == "__main__":
    main()
