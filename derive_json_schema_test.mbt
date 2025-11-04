///|
test {
  let source =
    #|///|
    #|/// doc for pos
    #|#json.schema
    #|struct Pos {
    #|  #json.enumerate(string("a", "b", "c"))
    #|  v : String
    #|  w : Array[Int]
    #|  /// doc for x
    #|  /// doc2
    #|  #json.default(string("*"))
    #|  x : String?
    #|  /// doc for y
    #|  #json.default(boolean(false))
    #|  y : Bool?
    #|  /// doc for z
    #|  z : Int?
    #|}
    #|
    #|/// doc for location
    #|#json.schema
    #|struct Location {
    #|  /// start pos
    #|  start : Pos?
    #|  /// end pos
    #|  end : Pos
    #|  points : Array[Pos]
    #|}
  let (ast, _) = @parser.parse_string(source)
  let ast = derive_json_schema(ast)
  let result = @formatter.impls_to_string(ast)
  inspect(
    result,
    content=(
      #|///|
      #|#json.generated
      #|fn Pos::get_schema() -> Json {
      #|  {
      #|    "type": "object",
      #|    "required": ["v", "w"],
      #|    "properties": {
      #|      "v": { "type": "string", "enum": ["a", "b", "c"] },
      #|      "w": { "type": "array", "items": { "type": "integer" } },
      #|      "x": {
      #|        "type": "string",
      #|        "default": "*",
      #|        "description": "doc for x\ndoc2",
      #|      },
      #|      "y": { "type": "boolean", "default": false, "description": "doc for y" },
      #|      "z": { "type": "integer", "description": "doc for z" },
      #|    },
      #|    "description": "\ndoc for pos",
      #|  }
      #|}
      #|
      #|///|
      #|#json.generated
      #|fn Location::get_schema() -> Json {
      #|  {
      #|    "type": "object",
      #|    "required": ["end", "points"],
      #|    "properties": {
      #|      "start": { "$ref": "#/definitions/Pos", "description": "start pos" },
      #|      "end": { "$ref": "#/definitions/Pos", "description": "end pos" },
      #|      "points": { "type": "array", "items": { "$ref": "#/definitions/Pos" } },
      #|    },
      #|    "description": "doc for location",
      #|    "definitions": { "Pos": Pos::get_schema() },
      #|  }
      #|}
      #|
      #|

    ),
  )
}

///|
test "panic - invalid T with default" {
  let source =
    #|#json.schema
    #|struct Pos {
    #|  #json.default(integer("10"))
    #|  w : Int
    #|}
  let (ast, _) = @parser.parse_string(source)
  let _ = derive_json_schema(ast)

}

///|
test "panic - invalid nested option" {
  let source =
    #|#json.schema
    #|struct Pos {
    #|  w : Int??
    #|}
  let (ast, _) = @parser.parse_string(source)
  let _ = derive_json_schema(ast)

}

///|
test "array with nullable" {
  let source =
    #|#json.schema
    #|struct Pos {
    #|  w : Array[Int?]
    #|}
  let (ast, _) = @parser.parse_string(source)
  let ast = derive_json_schema(ast)
  let result = @formatter.impls_to_string(ast)
  inspect(
    result,
    content=(
      #|///|
      #|#json.generated
      #|fn Pos::get_schema() -> Json {
      #|  {
      #|    "type": "object",
      #|    "required": ["w"],
      #|    "properties": {
      #|      "w": { "type": "array", "items": { "type": ["integer", "null"] } },
      #|    },
      #|  }
      #|}
      #|
      #|
    ),
  )
}
