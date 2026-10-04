def {factory_name}({params}) -> {ReturnType}:
    """
    {one_line_summary}

    Extended description of purpose and when to use vs alternatives.

    Args:
        {arg_name} ({type}): {description}.

    Returns:
        {ReturnType}: {description of returned object structure}.

    Examples:
        >>> # Basic usage
        >>> result = {factory_name}({basic_args})
        >>> result.is_success()
        True

        >>> # With all parameters
        >>> from dataclasses import dataclass
        >>> @dataclass
        ... class {DetailsClass}:
        ...     {field}: {type}
        >>> result = {factory_name}({full_args})
        >>> result.details.{field}
        {expected_value}

    See Also:
        {other_factory}: {when to use that instead}
        {RelatedClass}.{method}: {related functionality}
    """
    {implementation}
