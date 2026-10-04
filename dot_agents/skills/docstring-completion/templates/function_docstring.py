def {function_name}({params}) -> {ReturnType}:
    """
    {one_line_summary_imperative}

    Extended description (1-3 paragraphs) explaining:
    - What it does in more detail
    - Side effects, state changes, I/O
    - Preconditions or assumptions
    - Algorithm/approach if non-obvious

    Args:
        {param_name} ({type}): {description including constraints, valid ranges, or purpose}.
        {param_name} ({type}): {description}. Defaults to `{default}`.

    Returns:
        {ReturnType}: {description of what is returned, including structure if complex}.

    Raises:
        {ExceptionType}: {when/why this exception is raised}.

    Yields:
        {YieldType}: {description for generators}.

    Examples:
        >>> # Minimal working example with imports
        >>> from {module} import {function_name}
        >>> result = {function_name}({example_args})
        >>> result
        {expected_output}

        >>> # Example showing optional parameters
        >>> {function_name}({example_args_with_optional})
        {expected_output}

    See Also:
        {related_function}: {brief_description}
        {RelatedClass}.{method}: {brief_description}
    """
    {implementation}
