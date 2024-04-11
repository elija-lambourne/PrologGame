"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const fs_1 = __importDefault(require("fs"));
const path_1 = __importDefault(require("path"));
function convertToSf(input) {
    // Split the string with the char 'v', filter out invalid lines, and map to the desired format
    return input.split("v")
        .slice(1)
        .map(line => line.split(" "))
        .filter(parts => parts.length > 3 && !["f", "s"].some(char => parts.slice(0, 3).some(part => part.includes(char))))
        .map(parts => `[${parts[1]},${parts[2]},${parts[3].trimEnd()}]`)
        .join(",");
}
function convertIndices(input) {
    // Split the string with the char 'f', filter out invalid parts, and map to the desired format
    return "[" + input.split("f")
        .slice(1)
        .flatMap(line => line.split(" "))
        .map(part => part.split("/")[0])
        .filter(index => !Number.isNaN(parseInt(index)))
        .map(index => `${parseInt(index) - 1}`)
        .join(",") + "]";
}
function main() {
    const filePath = process.argv[2];
    if (filePath === undefined) {
        console.log("Error: No path to OBJ given!");
        return;
    }
    const extensionName = path_1.default.extname(filePath);
    if (extensionName !== ".obj") {
        console.log("Error: Only obj file format is currently supported");
        return;
    }
    const file = fs_1.default.readFileSync(filePath, "utf8");
    const string = convertToSf(file);
    const indices = convertIndices(file);
    let fileName = path_1.default.basename(filePath, extensionName).replace(/\W/g, '');
    fileName = fileName.charAt(0).toLowerCase() + fileName.slice(1);
    const res = `${fileName}` + `([${string}],${indices}).`;
    if (!fs_1.default.existsSync("./out")) {
        fs_1.default.mkdirSync("./out");
    }
    fs_1.default.writeFileSync(`./out/${fileName}.plo`, res);
    console.log(`[${new Date().toUTCString()}]` + " Conversion successful!");
}
main();
