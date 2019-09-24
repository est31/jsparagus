PY_OUT = js_parser/parser_tables.py
RS_TABLES_OUT = rust/generated_parser/src/parser_tables_generated.rs
RS_AST_OUT = rust/ast/src/types.rs rust/ast/src/visit.rs rust/generated_parser/src/stack_value_generated.rs
PYTHON = python3

all: $(PY_OUT) $(RS_AST_OUT) $(RS_TABLES_OUT)

ECMA262_SPEC_HTML = ../tc39/ecma262/spec.html
STANDARD_ES_GRAMMAR_OUT = js_parser/es.esgrammar

# Incomplete list of files that contribute to the dump file.
SOURCE_FILES = \
jsparagus/gen.py \
js_parser/esgrammar.pgen \
js_parser/generate_js_parser_tables.py \
js_parser/parse_esgrammar.py \
js_parser/es-simplified.esgrammar

EMIT_FILES = $(SOURCE_FILES) jsparagus/emit.py

DUMP_FILE = js_parser/parser_generated.jsparagus_dump

$(DUMP_FILE): $(SOURCE_FILES)
	$(PYTHON) -m js_parser.generate_js_parser_tables --progress -o $@

$(PY_OUT): $(EMIT_FILES) $(DUMP_FILE)
	$(PYTHON) -m js_parser.generate_js_parser_tables --progress -o $@ $(DUMP_FILE)

$(RS_AST_OUT): rust/ast/ast.json rust/ast/generate_ast.py
	(cd rust/ast && $(PYTHON) generate_ast.py)
	(cd rust && cargo fmt -- $(subst rust/,,$(RS_AST_OUT)))

$(RS_TABLES_OUT): $(EMIT_FILES) $(DUMP_FILE)
	$(PYTHON) -m js_parser.generate_js_parser_tables --progress -o $@ $(DUMP_FILE)

# This isn't part of the `all` target because it relies on a file that might
# not be there -- it lives in a different git respository.
$(STANDARD_ES_GRAMMAR_OUT): $(ECMA262_SPEC_HTML)
	$(PYTHON) -m js_parser.extract_es_grammar $(ECMA262_SPEC_HTML) > $@ || rm $@

check: $(PY_OUT)
	./test.sh

jsdemo: $(PY_OUT)
	$(PYTHON) -m js_parser.try_it

.PHONY: all check jsdemo
