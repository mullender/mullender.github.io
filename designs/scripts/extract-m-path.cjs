// Extract the Comfortaa "m" glyph at weight 700 as an SVG path,
// centered in a 128x128 viewBox at font-size 105.
//
// Usage:
//   1. curl -sSL -o Comfortaa.ttf 'https://github.com/google/fonts/raw/main/ofl/comfortaa/Comfortaa%5Bwght%5D.ttf'
//   2. npm install opentype.js
//   3. node extract-m-path.cjs > m-path.txt
//
// Then paste the path data into the <path d="..."/> of the *-outlined.svg files
// (favicon-com-outlined.svg, favicon-nl-outlined.svg, favicon-dev-outlined.svg).

const opentype = require('opentype.js');
const { readFileSync } = require('fs');

const buffer = readFileSync('./Comfortaa.ttf');
const font = opentype.parse(buffer.buffer.slice(buffer.byteOffset, buffer.byteOffset + buffer.byteLength));
font.variation.set({ wght: 700 });

const glyph = font.charToGlyph('m');
const fontSize = 105;
const scale = fontSize / font.unitsPerEm;
const glyphAdvance = glyph.advanceWidth * scale;
const yMin = (glyph.yMin || 0) * scale;
const yMax = (glyph.yMax || 0) * scale;

const cx = 64, cy = 64;
const startX = cx - glyphAdvance / 2;
const baseline = cy + (yMin + yMax) / 2;

const path = font.getPath('m', startX, baseline, fontSize);
console.log(path.toPathData(2));
