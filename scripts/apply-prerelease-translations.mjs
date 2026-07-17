// CLI wrapper: applies a TransSuperpre per-language bundle onto a merged
// pre-release cdb (texts only; datas stay mycard-authoritative).
import { applyTranslations } from "./build-prerelease-cdb.mjs";

const [cdbPath, translationCdbPath] = process.argv.slice(2);
if (!cdbPath || !translationCdbPath) {
	console.error("usage: node scripts/apply-prerelease-translations.mjs <cdb> <translationCdb>");
	process.exit(1);
}
const translated = applyTranslations(cdbPath, translationCdbPath);
console.log(`Applied ${translated} translated texts from ${translationCdbPath} onto ${cdbPath}`);
