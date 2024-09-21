--- AST scope, i.e. where a validation applies
--- @class Scope

--- @alias error {msg: string, pos: Cursor}
--- @alias ValidatorFilter fun(string): boolean, error
--- @alias AstValidatorFilter fun(AST, Scope): boolean, error

--- @alias TransformerFilter fun(string): string

--- @class Filters
--- @field validators ValidatorFilter[]
--- @field astValidators AstValidatorFilter[]
--- @field transformers TransformerFilter[]
