import {
  existsSync,
  lstatSync,
  mkdirSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(scriptDir, "..");
const rootVoltaire = path.join(
  projectRoot,
  "node_modules",
  "@tevm",
  "voltaire",
);
const localVoltaireTs = path.resolve(
  projectRoot,
  "../../voltaire/packages/voltaire-ts",
);

const isVoltairePackage = (packageDir) => {
  const packageJsonPath = path.join(packageDir, "package.json");
  const runtimeEntryPath = path.join(
    packageDir,
    "dist",
    "primitives",
    "AccessList",
    "index.js",
  );
  if (!existsSync(packageJsonPath)) {
    return false;
  }
  if (!existsSync(runtimeEntryPath)) {
    return false;
  }

  try {
    const content = readFileSync(packageJsonPath, "utf8");
    const parsed = JSON.parse(content);
    return parsed.name === "@tevm/voltaire";
  } catch {
    return false;
  }
};

const preferredTarget = isVoltairePackage(rootVoltaire)
  ? rootVoltaire
  : isVoltairePackage(localVoltaireTs)
    ? localVoltaireTs
    : null;

const patchOptionalContextCall = (filePath) => {
  if (!existsSync(filePath)) {
    return false;
  }

  const source = readFileSync(filePath, "utf8");
  const patched = source.replaceAll(
    "ctx?.onTestFinished(",
    "ctx?.onTestFinished?.(",
  );
  if (patched === source) {
    return false;
  }

  writeFileSync(filePath, patched);
  return true;
};

const patchEffectVitest = () => {
  patchOptionalContextCall(
    path.join(
      projectRoot,
      "node_modules",
      "@effect",
      "vitest",
      "dist",
      "esm",
      "internal.js",
    ),
  );
  patchOptionalContextCall(
    path.join(
      projectRoot,
      "node_modules",
      "@effect",
      "vitest",
      "dist",
      "cjs",
      "internal.js",
    ),
  );
};

if (preferredTarget !== null) {
  const peerNamespaceDir = path.join(
    projectRoot,
    "node_modules",
    "voltaire-effect",
    "node_modules",
    "@tevm",
  );
  const peerVoltaire = path.join(peerNamespaceDir, "voltaire");

  mkdirSync(peerNamespaceDir, { recursive: true });

  const hasValidPeerPackage = () => {
    if (!existsSync(peerVoltaire)) {
      return false;
    }

    try {
      lstatSync(peerVoltaire);
      return isVoltairePackage(peerVoltaire);
    } catch {
      return false;
    }
  };

  if (!hasValidPeerPackage()) {
    rmSync(peerVoltaire, { recursive: true, force: true });
    const relativeTarget = path.relative(peerNamespaceDir, preferredTarget);
    symlinkSync(relativeTarget, peerVoltaire, "dir");
  }
}

patchEffectVitest();
