from linter import check_test_code


def test_no_violations_general():
    """Test case for code with no violations."""
    code = """
function test_addition() {
    const a = 1;
    const b = 2;
    expect(a + b).toBe(3);
}
"""
    violations = check_test_code(code)
    assert not violations


def test_branching_logic_general():
    """Test case for code with branching logic."""
    code = """
def test_something():
    if x > 0:
        assert True
"""
    violations = check_test_code(code)
    assert (
        'Branching logic found. Tests should be declarative and avoid control flow.'
    ) in violations


def test_no_assertions_general():
    """Test case for code with no assertions."""
    code = """
func myTest() {
    let x = 10;
}
"""
    violations = check_test_code(code)
    assert 'No clear assertion found. Tests should verify outcomes with assertions.' in violations


def test_short_test_name_general():
    """Test case for a test with a short, non-descriptive name."""
    code = """
function test_a() {
    expect(true).toBe(true);
}
"""
    violations = check_test_code(code)
    assert (
        "Test name 'test_a' is too short or not descriptive. Consider a more meaningful name."
    ) in violations


def test_commented_out_test_general():
    """Test case for commented-out test code."""
    code = """
// function test_disabled() {
//     expect(false).toBe(true);
// }
"""
    violations = check_test_code(code)
    assert (
        "Commented-out test found: '// function test_disabled() {'. Remove or uncomment."
    ) in violations
