import assert from "node:assert/strict";
import { test } from "node:test";

import { fillStrings, parseArgs, parseEntries } from "./fill-edopro-strings.mjs";

const REFERENCE = [
	"!system 573 Add the card(s) to your hand",
	"!system 576 Select the card(s) to change its ATK/DEF",
	'!system 97 Place "%ls" in the Spell & Trap Zone?',
	"!counter 0x55 Hammer Counter",
	"!victory 0x20 Match Victory by the effect of %ls",
].join("\n");

test("parseArgs requires the four files", () => {
	assert.throws(() => parseArgs(["--base", "a"]), /--fill/);
	assert.deepEqual(parseArgs(["--base", "a", "--fill", "b", "--reference", "c", "--out", "d"]), {
		base: "a",
		fill: "b",
		reference: "c",
		out: "d",
	});
});

test("parseEntries reads entries and skips comments, blanks and other lines", () => {
	const entries = parseEntries("#comment\n\n!system 573 Añade la carta\n!setname 0x1 Aliado de la Justicia\nnoise\n");
	assert.deepEqual([...entries.keys()], ["system:573", "setname:1"]);
});

test("keeps the base file as it is and appends only what it lacks", () => {
	const base = "#Español\n!system 573 Añade la carta a la mano\n";
	const fill = "!system 573 Otra traducción\n!system 576 Elige la(s) carta(s) para cambiar su ATK/DEF\n";

	const { text, added } = fillStrings(base, fill, REFERENCE);

	assert.equal(added, 1);
	assert.equal(text, `${base}!system 576 Elige la(s) carta(s) para cambiar su ATK/DEF\n`);
});

test("returns the base file untouched when nothing is missing", () => {
	const base = "!system 573 Añade la carta a la mano";

	assert.deepEqual(fillStrings(base, "!system 573 Otra\n", REFERENCE), { text: base, added: 0 });
});

test("treats a hexadecimal and a decimal id as the same entry", () => {
	const { added } = fillStrings("!counter 85 Contador Martillo\n", "!counter 0x55 Otro nombre\n", REFERENCE);

	assert.equal(added, 0);
});

test("fills counters and victory reasons, not only system strings", () => {
	const { text } = fillStrings("", "!counter 0x55 Contador Martillo\n!victory 0x20 Victoria de Duelo por el efecto de %ls\n", REFERENCE);

	assert.match(text, /!counter 0x55 Contador Martillo/);
	assert.match(text, /!victory 0x20 Victoria de Duelo por el efecto de %ls/);
});

test("leaves out an entry the reference does not define", () => {
	assert.equal(fillStrings("", "!system 9999 Texto viejo\n", REFERENCE).added, 0);
});

test("leaves out an entry whose placeholders differ from the reference", () => {
	const fill = '!system 97 ¿Colocar en la Zona de Mágicas y Trampas?\n!system 576 Elige "%ls"\n';

	assert.equal(fillStrings("", fill, REFERENCE).added, 0);
});
