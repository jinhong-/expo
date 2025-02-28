import * as React from 'react';

import { AdditionalProps } from './headingManager';

import Permalink from '~/components/Permalink';
import { Code, InlineCode } from '~/components/base/code';
import { H1, H2, H3, H4 } from '~/components/base/headings';
import Link from '~/components/base/link';
import { UL, OL, LI } from '~/components/base/list';
import { PDIV, B, Quote } from '~/components/base/paragraph';
import { BareWorkflowCollapsible, ExpoKitCollapsible } from '~/ui/components/Collapsible';
import { Cell, HeaderCell, Row, Table, TableHead } from '~/ui/components/Table';
import { KBD } from '~/ui/components/Text';

type Options = {
  customIconStyle?: React.CSSProperties;
  baseNestingLevel?: number;
};

type PermalinkedComponentProps = React.PropsWithChildren<{ level?: number } & AdditionalProps>;

const createPermalinkedComponent = (
  BaseComponent: React.ComponentType<React.PropsWithChildren<object>>,
  options?: Options
) => {
  const { customIconStyle, baseNestingLevel } = options || {};
  return ({ children, level, ...props }: PermalinkedComponentProps) => {
    const nestingLevel = baseNestingLevel != null ? (level ?? 0) + baseNestingLevel : undefined;
    return (
      <Permalink
        nestingLevel={nestingLevel}
        customIconStyle={customIconStyle}
        additionalProps={props}>
        <BaseComponent>{children}</BaseComponent>
      </Permalink>
    );
  };
};

// When using inline markdown, we need to remove the document layout wrapper.
// Always set this to `null` to overwrite the global MDX provider.
export const wrapper = null;

export const p = PDIV;
export const strong = B;
export const ul = UL;
export const li = LI;
export const ol = OL;
export const h1 = createPermalinkedComponent(H1, { baseNestingLevel: 1 });
export const h2 = createPermalinkedComponent(H2, { baseNestingLevel: 2 });
export const h3 = createPermalinkedComponent(H3, { baseNestingLevel: 3 });
export const h4 = createPermalinkedComponent(H4, { baseNestingLevel: 4 });
export const code = Code;
export const inlineCode = InlineCode;
export const a = Link;
export const blockquote = Quote;
export const table = Table;
export const thead = TableHead;
export const tr = Row;
export const th = HeaderCell;
export const td = Cell;
export const kbd = KBD;
export const expokitDetails = ExpoKitCollapsible;
export const bareworkflowDetails = BareWorkflowCollapsible;
export const propertyAnchor = createPermalinkedComponent(PDIV, {
  baseNestingLevel: 3,
});
export const subpropertyAnchor = createPermalinkedComponent(PDIV, {
  baseNestingLevel: 3,
});
