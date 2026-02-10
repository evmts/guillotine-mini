import React from "react";
import { renderToStaticMarkup } from "react-dom/server";
import type { MDXContent } from "mdx/types";

type PromptComponent = MDXContent | ((props: Record<string, any>) => string);

export function render(
  Component: PromptComponent,
  props: Record<string, any> = {},
): string {
  // Plain TS function — just call it
  if (typeof Component === "function" && !Component.prototype?.isReactComponent) {
    try {
      const result = Component(props);
      if (typeof result === "string") return result.trim();
    } catch {
      // Fall through to MDX rendering
    }
  }

  // MDX component — render via React
  const html = renderToStaticMarkup(React.createElement(Component as MDXContent, props));
  return html
    .replace(/<[^>]+>/g, "")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#x27;/g, "'")
    .replace(/&#x2F;/g, "/")
    .replace(/\n{3,}/g, "\n\n")
    .trim();
}
