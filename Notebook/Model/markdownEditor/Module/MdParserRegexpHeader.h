//
//  MdParserRegexpHeader.h
//  Notebook
//
//  Created by teason23 on 2019/3/13.
//  Copyright © 2019 teason23. All rights reserved.
//

#ifndef MdParserRegexpHeader_h
#define MdParserRegexpHeader_h

#define regexp(reg,option)      [NSRegularExpression regularExpressionWithPattern:@reg options:option error:NULL]

typedef NS_ENUM(NSUInteger, MarkdownSyntaxType){
    MarkdownSyntaxUnknown,
    
    // 标题
    MarkdownSyntaxHeaders, // h1-h6
//    MarkdownSyntaxLHeader, // line header  ====的上面一行
    
    // block
    MarkdownSyntaxBlockquotes, // 块引用
    MarkdownSyntaxCodeBlock, // 代码块
    MarkdownSyntaxHr, // 分割线
    
    // 列表
    MarkdownSyntaxTaskLists, // tasklist
    MarkdownSyntaxOLLists, // orderlist
    MarkdownSyntaxULLists, // bulletlist
    MarkdownSyntaxTaskList_Checkbox ,
    MarkdownSyntaxULLists_Bullet ,
    
    // 行内样式
    MarkdownSyntaxBold, // 粗体
    MarkdownSyntaxItalic, // 斜体
    MarkdownSyntaxBoldItalic, // 粗体+斜体
    MarkdownSyntaxDeletions, // 删除线
    MarkdownSyntaxInlineCode, // 行内代码
    MarkdownSyntaxLinks, // 链接
    
    // other
    MarkdownSyntaxNewLine, // 换行
    MarkdownSyntaxCode, // 代码缩进格式
    MarkdownSyntaxDef,
    MarkdownSyntaxParagraph,
    MarkdownSyntaxText,
    MarkdownSyntaxFrontMatter,
    MarkdownSyntaxMultipleMath, //  数学
    
    NumberOfMarkdownSyntax // count  优先级从高到低.
} ;


#define MDPR_newline            "^\\n+"
#define MDPR_code               "^( {4}[^\\n]+\\n*)+"
#define MDPR_hr                 "^( *[-*_]){3,} *(?:\\n)"
#define MDPR_heading            "^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)"
#define MDPR_lheading           "^([^\\n]+)\\n *(=|-){2,} *(?:\\n+|$)"

#define MDPR_blockquote         "^( {0,3}> ?(^([^\\n]+(?:\\n?(?!^( *[-*_]){3,} *(?:\\n+|$)|^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)|^([^\\n]+)\\n *(=|-){2,} *(?:\\n+|$)| {0,3}>)[^\\n]+)+)|[^\\n]*)(?:\\n|$))+"

#define MDPR_tasklist           "^( *)([*+-] \\[(?:X|x|\\s)\\]) [\\s\\S]+?(?:^( *[-*_]){3,} *(?:\\n+|$)|^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)|\\n{2,}(?! )(?!\\1(?:[*+-] \\[(?:X|x|\\s)\\]))\\n*|\\s*$)"
#define MDPR_orderlist          "^( *)(\\d+\\.) [\\s\\S]+?(?:^( *[-*_]){3,} *(?:\\n+|$)|^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)|\\n{2,}(?! )(?!\\1\\d+\\. )\\n*|\\s*$)"
#define MDPR_bulletlist         "^( *)([*+-]) [\\s\\S]+?(?:^( *[-*_]){3,} *(?:\\n+|$)|^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)|\\n{2,}(?! )(?!\1[*+-] )\\n*|\\s*$)"

#define MDPR_def                "^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)"

#define MDPR_paragraph          "^([^\\n]+(?:\\n?(?!^( *[-*_]){3,} *(?:\\n+|$)|^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)|^([^\\n]+)\\n *(=|-){2,} *(?:\\n+|$)| {0,3}>)[^\\n]+)+)"

#define MDPR_text               "^[^\\n]+"

#define MDPR_frontmatter        "^---\\n([\\s\\S]+?)---(?:\\n+|$)"
#define MDPR_multiplemath       "^\\$\\$\\n([\\s\\S]+?)\\n\\$\\$(?:\\n+|$)"

#define MDPR_checkbox           "^\\[([ x])\\] +"
#define MDPR_bullet             "(?:[*+-] \\[(?:X|x|\\s)\\]|[*+-]|\\d+\\.)"

#endif /* MdParserRegexpHeader_h */