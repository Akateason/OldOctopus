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



/** MarkStyle TYPE
 * the priroty from low to high
 *** MarkdownSyntaxParagraph == -1 ;
 */

// block TYPE
typedef NS_ENUM(int, MarkdownSyntaxType){
    MarkdownSyntaxUnknown,
    
    // 标题
    MarkdownSyntaxHeaders, // h1-h6
//    MarkdownSyntaxLHeader, // line header  ====的上面一行
    
    // 列表
    MarkdownSyntaxOLLists, // orderlist
    MarkdownSyntaxULLists, // bulletlist
    MarkdownSyntaxTaskLists, // tasklist
    
//    MarkdownSyntaxTaskList_Checkbox ,   // not in parse
//    MarkdownSyntaxULLists_Bullet ,      // not in parse
    
    // block
    MarkdownSyntaxBlockquotes, // 块引用
    MarkdownSyntaxCodeBlock, // 代码块
    
    // other
    MarkdownSyntaxMultipleMath, //  数学
    MarkdownSyntaxHr, // 分割线
    
    MarkdownSyntaxTable ,    
    
    NumberOfMarkdownSyntax // count  优先级从低到高.
} ;

// inline TYPE
typedef NS_ENUM(int, MarkdownInlineType){
    MarkdownInlineUnknown = 99,
    
    MarkdownInlineBold,
    MarkdownInlineItalic,
    MarkdownInlineBoldItalic,
    MarkdownInlineDeletions,
    MarkdownInlineInlineCode,
    MarkdownInlineLinks,
    
    MarkdownInlineImage = 200,
    MarkdownInlineEscape ,
    
    NumberOfMarkdownInline
} ;




#define MDPR_newline            "^\\n+"
#define MDPR_code               "^( {4}[^\\n]+\\n*)+"
#define MDPR_hr                 "^( *[-*_]){3,} *(?:\\n)"
#define MDPR_heading            "^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)"
#define MDPR_lheading           "^([^\\n]+)\\n *(=|-){2,} *(?:\\n+|$)"

#define MDPR_blockquote         "^( {0,3}> ?(^([^\\n]+(?:\\n?(?!^( *[-*_]){3,} *(?:\\n+|$)|^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)|^([^\\n]+)\\n *(=|-){2,} *(?:\\n+|$)| {0,3}>)[^\\n]+)+)|[^\\n]*)(?:\\n|$))+"
#define MDPR_codeBlock          "(```)([\\s\\S]*?)(```)"
//#define MDPR_codeBlock          "^ {0,3}(`{3,}|~{3,})([^`\\n]*)\\n(?:|([\\s\\S]*?)\\n)(?: {0,3}\\1[~`]* *(?:\\n+|$)|$)"



#define MDPR_tasklist           "^( *)([*+-] \\[(?:X|x|\\s)\\]) [\\s\\S]+?(?:^( *[-*_]){3,} *(?:\\n+|$)|^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)|\\n{2,}(?! )(?!\\1(?:[*+-] \\[(?:X|x|\\s)\\]))\\n*|\\s*$)"

//#define MDPR_orderlist          "^( *)(\\d+\\.) [\\s\\S]+?(?:^( *[-*_]){3,} *(?:\\n+|$)|^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)|\\n{2,}(?! )(?!\\1\\d+\\. )\\n*|\\s*$)"
#define MDPR_orderlist          "^[\\s]*[0-9]+\\. +(.*)"

//#define MDPR_bulletlist         "^( *)([*+-]) [\\s\\S]+?(?:^( *[-*_]){3,} *(?:\\n+|$)|^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)|\\n{2,}(?! )(?!\1[*+-] )\\n*|\\s*$)"
#define MDPR_bulletlist         "^[\\s]*[-\\*\\+] +(.*)"



#define MDPR_def                "^ {0,3}\\[([^\\]]+)\\]: *<?([^\\s>]+)>?(?: +['(]([^\\n]+)[')])? *(?:\\n+|$)"

//#define MDPR_paragraph          "\n(*\n)\n"
//"^([^\\n]+(?:\\n?(?!^( *[-*_]){3,} *(?:\\n+|$)|^ *(#{1,6}) *([^\\n]+?) *(?:#+ *)?(?:\\n+|$)|^([^\\n]+)\\n *(=|-){2,} *(?:\\n+|$)| {0,3}>)[^\\n]+)+)"
//段落解析有问题. 无法解析连续紧列表等. 所以现在代码块,列表都是另外解析,都不是一个段落.
//去掉了正则匹配段落, 用换行去匹配段落, 然后根据一次换行的多少判断是大段落还是小段落. 这样更好了.

#define MDPR_text               "^[^\\n]+"

#define MDPR_frontmatter        "^---\\n([\\s\\S]+?)---(?:\\n+|$)"
#define MDPR_multiplemath       "(\\$\\$)([\\s\\S]*?)(\\$\\$)"


#define MDPR_checkbox           "^\\[([ x])\\] +"
#define MDPR_bullet             "(?:[*+-] \\[(?:X|x|\\s)\\]|[*+-]|\\d+\\.)"


#define MDPR_table              "^ *\\|(.+)\\n *\\|?( *[-:]+[-| :]*)(?:\\n((?: *[^>\\n ].*(?:\\n|$))*)\\n*|$)"


#define MDIL_BOLD               "(?<!\\*)\\*{2}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{2}(?!\\*)|(?<!\\_)\\_{2}(?=[^ \\t_])(.+?)(?<=[^ \\t_])\\_{2}(?!\\_)"

#define MDIL_ITALIC              "((?<!\\*)\\*(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*(?!\\*)|(?<!_)_(?=[^ \\t_])(.+?)(?<=[^ \\t_])_(?!_))"
#define MDIL_BOLDITALIC          "((?<!\\*)\\*{3}(?=[^ \\t*])(.+?)(?<=[^ \\t*])\\*{3}(?!\\*)|(?<!_)_{3}(?=[^ \\t_])(.+?)(?<=[^ \\t_])_{3}(?!_))"
#define MDIL_DELETION            "\\~\\~(.*?)\\~\\~"
#define MDIL_INLINECODE          "\\`(.*?)\\`"

#define MDIL_LINKURL             "(\\[)((?:\\[[^\\]]*\\]|[^\\[\\]]|\\](?=[^\\[]*\\]))*?)(\\\\*)\\]\\((.*?)(\\\\*)\\)"
#define MDIL_IMAGES              "(\\!\\[)(.*?)(\\\\*)\\]\\((.*?)(\\\\*)\\)"





#define MDIL_ESCAPE              "\\\\([!\"#$%&'()*+,\\-./:;<=>?@\\[\\]\\\\^_`{|}~])"




#endif /* MdParserRegexpHeader_h */
