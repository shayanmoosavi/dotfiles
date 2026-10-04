class {ClassName}:
    """
    {one_line_summary}

    Extended description (2-4 paragraphs) explaining:
    - What the class represents/encapsulates
    - Key responsibilities
    - Important attributes (especially Pydantic fields with Field())
    - Lifecycle/usage patterns
    - Configuration examples if the class maps to config

    Attributes:
        {attr_name} ({type}): {description}.
        {attr_name} ({type}): {description}. (computed)

    Configuration Example:
        ```toml title="{config_file}"
        [{section_name}]
        {key} = {value}  # {description}
        ```

    Examples:
        >>> from {module} import {ClassName}
        >>> obj = {ClassName}({param}={value})
        >>> obj.{method}()
        {expected_output}

    See Also:
        {RelatedClass}: {brief_description}
        {related_function}: {brief_description}
    """

    {attr_name}: {type} = Field(
        default={default},
        description="{field_description}"
    )
