Mapping:
  based on: strictyaml
  importance: 3
  description: |
    Mappings of one value to another are represented by : in YAML
    and parsed as python dicts.

    Using StrictYAML's 'Map' you can validate that a mapping
    contains the right keys and the right *type* of values.

    Note: for mappings where you don't know the exact names of
    the keys in advance but you do know the type, use MapPattern.
  preconditions:
    setup: |
      from collections import OrderedDict
      from strictyaml import Map, Int, load

      schema = Map({"a": Int(), "b": Int(), "c": Int()})

      schema_2 = Map({u"â": Int(), "b": Int(), "c": Int()})
    yaml_snippet: |
      â: 1
      b: 2
      c: 3

  variations:
    one key mapping:
      preconditions:
        yaml_snippet: 'x: 1'
        code: |
          load(yaml_snippet, Map({"x": Int()})).data
      scenario:
      - Should be equal to: |
          OrderedDict([('x', 1)])

    key value:
      preconditions:
        code: |
          load(yaml_snippet, schema_2)[u'â']
      scenario:
      - Should be equal to: 1

    get item key not found:
      preconditions:
        code: |
          load(yaml_snippet, schema_2)['keynotfound']
      scenario:
      - Raises exception:
          message: "'keynotfound'"

    cannot use .text:
      preconditions:
        code: |
          load(yaml_snippet, schema_2).text
      scenario:
      - Raises Exception:
          message: YAML(OrderedDict([('â', 1), ('b', 2), ('c', 3)])) is a mapping,
            has no text value.

    key not found in schema:
      preconditions:
        yaml_snippet: |
          a: 1
          b: 2
          â: 3
        code: |
          load(yaml_snippet, schema)
      scenario:
      - Raises Exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            while parsing a mapping
            unexpected key not in schema 'â'
              in "<unicode string>", line 3, column 1:
                "\xE2": '3'
                ^ (line: 3)

    sequence not expected:
      preconditions:
        yaml_snippet: |
          - 1
          - 2
          - 3
        code: load(yaml_snippet, schema)
      scenario:
      - Raises Exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            when expecting a mapping
              in "<unicode string>", line 1, column 1:
                - '1'
                 ^ (line: 1)
            found non-mapping
              in "<unicode string>", line 3, column 1:
                - '3'
                ^ (line: 3)

    unexpected key:
      preconditions:
        yaml_snippet: |
          a: 1
          b: 2
          c: 3
          d: 4
        code: |
          load(yaml_snippet, schema)
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            while parsing a mapping
            unexpected key not in schema 'd'
              in "<unicode string>", line 4, column 1:
                d: '4'
                ^ (line: 4)


    required key not found:
      preconditions:
        yaml_snippet: |
          a: 1
        code: |
          load(yaml_snippet, schema)
      scenario:
      - Raises exception:
          exception type: strictyaml.exceptions.YAMLValidationError
          message: |-
            while parsing a mapping
            required key(s) 'b', 'c' not found
              in "<unicode string>", line 1, column 1:
                a: '1'
                 ^ (line: 1)
