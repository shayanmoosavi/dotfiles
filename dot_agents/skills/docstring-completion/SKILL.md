---
name: docstring-completion
description: Complete and enhance Python docstrings using Google-style format with mkdocstrings-compatible markdown. Fills in missing descriptions, parameters, returns, examples, and adds module-level docstrings from minimal initial docstrings.
---

# Docstring Completion Skill

This skill helps complete and enhance Python docstrings following Google-style format with mkdocstrings-compatible markdown extensions (cross-references, admonitions, code blocks with titles). Use when you need to:

- Expand minimal docstrings (e.g., one-line summaries) into full documentation
- Add missing Args, Returns, Raises, Yields sections with proper types and descriptions
- Write realistic, runnable doctest examples
- Add module-level docstrings explaining purpose, architecture, and key classes
- Ensure consistency across a codebase

## When to Use

- A function/class has only a one-line summary docstring
- Parameters exist in the signature but are missing from Args
- No examples exist or examples are trivial/non-runnable
- Module lacks a top-level docstring explaining its role
- Docstrings need to follow your project's specific conventions (Google-style + mkdocstrings markdown)

## Documentation Style Reference

Your project uses **Google-style docstrings** with these mkdocstrings-specific enhancements:

### Cross-References (use only for public API / library modules)

For modules that appear in generated API documentation or are imported by other packages,
use cross-references. For small in-source helper scripts (e.g. `scripts/`), skip cross-references.

```markdown
[ClassName][ClassName] # Link to class in same module
[module.ClassName][module.ClassName] # Link to class in different module
```

### Code Blocks with Titles

````markdown
```toml title="tasks.toml"
[health-check]
type = "automated"
```
````

````

### Admonitions
```markdown
!!! note "Configuration Examples"
    This setting controls...

!!! warning
    Do not modify this in production.
````

### Doctest Examples

- Must be runnable (no `...` continuations unless truly needed)
- Include imports in the example
- Use `>>>` prompts
- Show expected output

### Doctest Validation

Run doctests with pytest to verify they pass:

```bash
uv run pytest --doctest-modules src/archcare/config/loader.py
```

The `--doctest-modules` flag is required for pytest to discover and run doctests in module docstrings.

## Workflow: Completing a Docstring

### 1. Analyze the Current State

```python
# Read the file and identify:
# - Current docstring (if any)
# - Function/class signature (parameters, return type, type hints)
# - Implementation logic (what it actually does)
# - Related classes/functions in the same module
```

### 2. Expand Following This Template

#### Module Docstring

```python
"""
One-sentence summary of module purpose.

Extended description (2-5 paragraphs) covering:
- What this module provides (key classes, functions, constants)
- How it fits into the overall architecture
- Key concepts/terminology
- Configuration examples if applicable
- Cross-references to main classes using [ClassName][ClassName] syntax (optional for small scripts)

See Also (optional for small scripts):
    related.module: Brief description of relationship
"""
```

#### Package `__init__.py` Docstring

```python
"""
One-sentence summary of package purpose.

Extended description (2-5 paragraphs) covering:
- What this package provides
- How it fits into the overall architecture
- Key concepts/terminology

Modules:
    module_name: Brief description of what this module provides.
    other_module: Brief description.

Public API:
    - ClassName: Brief description
    - function_name: Brief description
    - CONSTANT_NAME: Brief description

See Also (optional for small scripts):
    related.package: Brief description of relationship
"""
```

#### Class Docstring

```python
class ClassName:
    """
    One-sentence summary of class purpose.

    Extended description (2-4 paragraphs) explaining:
    - What the class represents/encapsulates
    - Key responsibilities
    - Important attributes (especially Pydantic fields with Field())
    - Lifecycle/usage patterns
    - Configuration examples if the class maps to config

    Attributes:
        attr_name (type): Description of the attribute.

    Examples (optional — skip for small in-source scripts):
        >>> obj = ClassName(param="value")
        >>> obj.method()
        'expected output'

    See Also (optional — skip for small in-source scripts):
        RelatedClass: Brief description
    """
```

#### Small Helper Scripts (e.g. `scripts/`)

For small in-source scripts that are not part of the public API and are not included
in generated documentation, keep docstrings concise. Skip `Examples` and `See Also`
sections, and omit cross-references. Focus on `Args`, `Returns` (or `Yields`), and `Raises`.

### Function/Method Docstring

```python
def function_name(param1: Type, param2: Type = default) -> ReturnType:
    """
    One-sentence summary of what the function does (imperative mood).

    Extended description (1-3 paragraphs) explaining:
    - What it does in more detail
    - Side effects, state changes, I/O
    - Preconditions or assumptions
    - Algorithm/approach if non-obvious

    Args:
        param1 (Type): Description including constraints, valid ranges, or purpose.
        param2 (Type): Description. Defaults to `default`.

    Returns:
        ReturnType: Description of what is returned, including structure if complex.

    Raises:
        ExceptionType: When/why this exception is raised.

    Yields:
        YieldType: Description for generators.

    Examples (optional — skip for small in-source scripts):
        >>> # Minimal working example with imports
        >>> from module import function_name
        >>> result = function_name("input")
        >>> result
        'expected_output'

        >>> # Example showing optional parameters
        >>> function_name("input", param2="custom")
        'expected_output'

    See Also (optional — skip for small in-source scripts):
        related_function: Brief description
    """
```

#### Enum Docstring

````python
class EnumName(Enum):
    """
    One-sentence summary of what this enum represents.

    Extended description explaining:
    - What the enum values mean conceptually
    - How they're used in configuration or logic
    - Any ordering/hierarchy implications

    Configuration Examples:
        ```toml title="config.toml"
        setting = "VALUE"  # Description
        ```

    Attributes:
        VALUE (str): Description of this value's meaning/usage.
    """

    VALUE = "value"
    """
    Description of this specific value.
    - Usage context
    - Typical scenarios
    """
````

#### Factory Function Docstring (like `success`, `failed`)

```python
def factory_function(arg: Type, ...) -> ReturnType:
    """
    One-sentence summary.

    Extended description of purpose and when to use vs alternatives.

    Args:
        arg (Type): Description.

    Returns:
        ReturnType: Description of returned object structure.

    Examples (optional — skip for small in-source scripts):
        >>> # Basic usage
        >>> result = factory_function("message")
        >>> result.is_success()
        True

        >>> # With all parameters
        >>> from dataclasses import dataclass
        >>> @dataclass
        ... class Details:
        ...     count: int
        >>> result = factory_function("msg", details=Details(count=5))
        >>> result.details.count
        5

    See Also (optional — skip for small in-source scripts):
        other_factory: When to use that instead
    """
```

### 3. Specific Rules for Your Stack

| Element               | Convention                                                                                                          |
| --------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Summary line**      | Imperative mood ("Create...", "Return...", "Validate..."), not "Creates...", "Returns..."                           |
| **Args descriptions** | Include constraints: "Must be positive", "Defaults to 30", "Valid values: 'auto', 'manual'"                         |
| **Cross-refs**        | Always use `[ClassName][ClassName]` for classes in same module; `[module.ClassName][module.ClassName]` for external |
| **Code blocks**       | Use `title="filename"` for config examples; no title for pure Python                                                |
| **Doctests**          | Include all imports; use realistic data; avoid `...` unless output is non-deterministic                             |
| **Pydantic models**   | Document `Field()` descriptions in class docstring Attributes section, not in `__init__`                            |
| **Computed fields**   | Document in Attributes with "(computed)" suffix                                                                     |
| **Validators**        | Mention in class docstring if they enforce non-obvious constraints                                                  |

### 4. Quality Checklist

Before considering a docstring complete, verify:

- [ ] Summary line is imperative, one sentence, ends with period
- [ ] All parameters in signature appear in Args (no more, no less)
- [ ] All return values documented in Returns
- [ ] All raised exceptions documented in Raises
- [ ] Types in Args/Returns match signature annotations
- [ ] At least one runnable doctest example per public function/method (optional for small scripts)
- [ ] Cross-references use correct `[Name][Name]` syntax (only for public API / library modules)
- [ ] Config examples use correct `title="file.toml"` format
- [ ] No placeholder text ("TODO", "FIXME", "description here")
- [ ] Consistent terminology with rest of module
- [ ] Doctests pass with `pytest --doctest-modules <module_path>`

## Example Transformation

### Before (minimal)

```python
def calculate_due_date(frequency: int, last_run: datetime) -> datetime:
    """Calculate next due date."""
    return last_run + timedelta(days=frequency)
```

### After (complete)

```python
def calculate_due_date(frequency: int, last_run: datetime) -> datetime:
    """
    Calculate the next due date for a recurring task.

    Adds the frequency interval (in days) to the last run timestamp to determine
    when the task should next execute. This is used by the scheduler to track
    automated task deadlines.

    Args:
        frequency (int): Number of days between scheduled runs. Must be positive.
            Typical values: 1 (daily), 7 (weekly), 30 (monthly).
        last_run (datetime): Timestamp of the last successful task execution.
            Must be timezone-aware if the system uses timezone-aware datetimes.

    Returns:
        datetime: The next due date (last_run + frequency days), preserving
            the timezone info of `last_run`.

    Raises:
        ValueError: If `frequency` is not a positive integer.

    Examples:
        >>> from datetime import datetime, timedelta
        >>> last = datetime(2024, 1, 15, 10, 0, 0)
        >>> calculate_due_date(7, last)
        datetime.datetime(2024, 1, 22, 10, 0)

        >>> # Monthly frequency
        >>> calculate_due_date(30, last)
        datetime.datetime(2024, 2, 14, 10, 0)

    See Also:
        TaskScheduler.get_schedule_info: Uses this for due date calculation
    """
    if frequency <= 0:
        raise ValueError("frequency must be positive")
    return last_run + timedelta(days=frequency)
```

## Supporting Files

This skill includes templates in the `templates/` directory:

- `module_docstring.py` - Module-level docstring template
- `class_docstring.py` - Class docstring template
- `function_docstring.py` - Function/method docstring template
- `enum_docstring.py` - Enum docstring template
- `factory_docstring.py` - Factory function template

Reference these when creating new docstrings from scratch.
