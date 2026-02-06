declare module "*.mdx" {
  import type { MDXContent } from "mdx/types";
  const Component: MDXContent;
  export default Component;
}
