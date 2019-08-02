#!/usr/bin/env bash

INFILE=$1; shift
OUTFILE=$1; shift

m4 -P $@ - "$INFILE" <<'MACROS' | dot -Tsvg -o "$OUTFILE"

m4_changequote(«, »)
m4_changecom(«//»)

m4_ifdef(«_FONTNAME», «», «m4_define(«_FONTNAME», «Helvetica,sans»)»)
m4_ifdef(«_FONTSIZE», «», «m4_define(«_FONTSIZE», 12)»)

m4_define(«_COMPARTMENT», <tr><td sides="b" align="left" balign="left">$1</td></tr>)

m4_define(«_LABEL», «
    <table border="0" cellborder="1" cellspacing="0" cellpadding="4">
        <tr><td width="55" sides="b">$1</td></tr>
        m4_ifelse($2, «», «», _COMPARTMENT($2))
        m4_ifelse($3, «», «», _COMPARTMENT($3))
        m4_ifelse($4, «», «», _COMPARTMENT($4))
    </table>
»)

m4_define(«TYPE», «
    m4_ifdef(«_TYPES», «
        m4_define(«_TYPE», «$2 $1»)
        m4_ifdef(«_ABSTRACT», «m4_define(«_TYPE», <i>_TYPE</i>)»)
        m4_define(«_TYPES», _TYPES«»_TYPE<br/>)
        m4_undefine(«_TYPE», «_ABSTRACT»)
    », «
        m4_define(«_LITERALS»)
        m4_define(«_ATTRIBUTES»)
        m4_define(«_OPERATIONS»)
        m4_define(«_TYPE», m4_ifelse($2, «», «\N», «$2<br/>\N»))
        m4_ifdef(«_ABSTRACT», «m4_define(«_TYPE», <i>_TYPE</i>)»)
        m4_undefine(«_ABSTRACT»)
        m4_pushdef(«END», «
            label=<_LABEL(_TYPE, _LITERALS, _ATTRIBUTES, _OPERATIONS)> ]
            m4_undefine(«_TYPE», «_LITERALS», «_ATTRIBUTES», «_OPERATIONS»)
            m4_popdef(«END»)
        »)
        "$1" [ shape=box margin=0
    »)
»)

m4_define(«CLASS», «TYPE($1)»)
m4_define(«INTERFACE», «TYPE($1, interface)»)
m4_define(«ENUMERATION», «TYPE($1, enumeration)»)
m4_define(«PROTOCOL», «TYPE($1, protocol)»)

m4_define(«_MODIFIER», «m4_define(«$1», «m4_define(«_$1»)»)»)

_MODIFIER(«ABSTRACT»)
_MODIFIER(«STATIC»)
_MODIFIER(«BIDIRECTIONAL»)
_MODIFIER(«BEHAVIOR»)
_MODIFIER(«WEAK»)
// _MODIFIER(«ACTIVE»)

m4_define(«TYPES», «
    m4_ifdef(«_ABSTRACT», «
        TYPE($2, $1) END
        m4_ifelse($3, «», «», «ABSTRACT TYPES($1, m4_shift(m4_shift($@)))»)
    », «
        TYPE($2, $1) END
        m4_ifelse($3, «», «», «TYPES($1, m4_shift(m4_shift($@)))»)
    »)
»)

m4_define(«CLASSES», «TYPES(«», $@)»)
m4_define(«INTERFACES», «TYPES(interface, $@)»)
m4_define(«ENUMERATIONS», «TYPES(enumeration, $@)»)
m4_define(«PROTOCOLS», «TYPES(protocol, $@)»)

m4_define(«ATTRIBUTE», «
    m4_define(«_ATTRIBUTE», $1)
    m4_ifdef(«_STATIC», «m4_define(«_ATTRIBUTE», <u>_ATTRIBUTE</u>)»)
    m4_ifdef(«_ABSTRACT», «m4_define(«_ATTRIBUTE», <i>_ATTRIBUTE</i>)»)
    m4_define(«_ATTRIBUTES», _ATTRIBUTES«»_ATTRIBUTE<br/>)
    m4_undefine(«_ATTRIBUTE», «_STATIC», «_ABSTRACT»)
»)

m4_define(«OPERATION», «
    m4_define(«_OPERATION», m4_ifelse($2, «», $1, «$1 &#8594; $2»))
    m4_ifdef(«_STATIC», «m4_define(«_OPERATION», <u>_OPERATION</u>)»)
    m4_ifdef(«_ABSTRACT», «m4_define(«_OPERATION», <i>_OPERATION</i>)»)
    m4_define(«_OPERATIONS», _OPERATIONS«»_OPERATION<br/>)
    m4_undefine(«_OPERATION», «_STATIC», «_ABSTRACT»)
»)

m4_define(«LITERAL», «m4_define(«_LITERALS», _LITERALS«»$1<br/>)»)

m4_define(«DIAGRAM», «
    digraph "$1" { label=<$1> fontname="_FONTNAME" fontsize=m4_eval(_FONTSIZE * 7/6)
    compound=true nodesep=0.5 labelloc=t
    node [ fontname="_FONTNAME" fontsize=_FONTSIZE ] edge [ fontname="_FONTNAME" fontsize=_FONTSIZE ]
    m4_ifdef(«_BEHAVIOR», «splines=curved node [ shape=Mrecord ]», «rankdir=BT node [ shape=box ]»)
    m4_undefine(«_BEHAVIOR»)
»)

m4_define(«_NOTE», 0)
m4_define(«NOTE», «
    m4_define(«_NOTE», m4_incr(_NOTE))
    { rank=same «note_»_NOTE [ shape=note label=<$1>]
    m4_ifelse($2, «», «», $2 -> «note_«»_NOTE [ style=dashed arrowhead=none ]»)
    }
»)

m4_define(«DEPENDENCIES», «
    { edge [ style=dashed arrowhead=open m4_ifdef(«_BIDIRECTIONAL», «dir=both arrowtail=open») ]
    m4_undefine(«_BIDIRECTIONAL»)
»)
m4_define(«ASSOCIATIONS», «
    { edge [ m4_ifdef(«_BIDIRECTIONAL», «arrowhead=none», «arrowhead=open») ]
    m4_undefine(«_BIDIRECTIONAL»)
»)
m4_define(«GENERALIZATIONS», «
    { edge [ arrowhead=empty m4_ifdef(«_BIDIRECTIONAL», «dir=both arrowtail=empty») ]
    m4_undefine(«_BIDIRECTIONAL»)
»)
m4_define(«IMPLEMENTATIONS», «{ edge [ arrowhead=empty style=dashed ] »)
m4_define(«AGGREGATIONS», «{ edge [ arrowtail=odiamond dir=both arrowhead=open ] »)
m4_define(«COMPOSITIONS», «{ edge [ arrowtail=diamond dir=both arrowhead=open ] »)
m4_define(«NESTINGS», «{ edge [ arrowhead=odot ] »)
m4_define(«CRUTCHES», «{ edge [ style=invis ] »)

_MODIFIER(«HORIZONTAL»)

m4_define(«RELATION», «
    {
    m4_ifdef(«_HORIZONTAL», «rank=same»)
    $1 [ label=<$2> taillabel=<$3> headlabel=<$4>
    m4_ifelse($5, «», «», «ltail="cluster $5"»)
    m4_ifelse($6, «», «», «lhead="cluster $6"»)
    m4_ifdef(«_WEAK», «constraint=false»)
    ] }
    m4_undefine(«_HORIZONTAL», «_WEAK»)
»)
m4_define(«TRANSITION», «RELATION($@)»)

m4_define(«END», «}»)

m4_define(«COMPONENT», «"$1" [ shape=component ]»)
m4_define(«COLLABORATION», «"$1" [ shape=ellipse style=dashed ]»)
m4_define(«USECASE», «"$1" [ shape=ellipse ]»)
m4_define(«NODE», «"$1" [ shape=box3d ]»)
m4_define(«ACTION», «"$1" [ shape=Mrecord m4_ifelse($2, «», «», «label=<$2>») ]»)
m4_define(«STATE», «"$1" [ shape=Mrecord m4_ifelse($2, «», «», «label=<$2>») ]»)
m4_define(«ENTITY», «"$1" [ shape=record m4_ifelse($2, «», «», «label=<$2>») ]»)
m4_define(«FORK», «"$1" [ label="" shape=underline style=bold width=1.5 height=0 ]»)
m4_define(«JOIN», «FORK($1)»)
m4_define(«DECISION», «"$1" [ shape=hexagon m4_ifelse($2, «», «», «label=<$2>») ]»)
m4_define(«MERGE», «"$1" [ label="" shape=hexagon ]»)
m4_define(«IO», «"$1" [ shape=parallelogram m4_ifelse($2, «», «», «label=<$2>») ]»)
m4_define(«INITIAL_NODE», «"$1" [ shape=circle label="" style=filled fillcolor=black width=0.25 ]»)
m4_define(«INITIAL_STATE», «INITIAL_NODE($1)»)
m4_define(«FINAL_NODE», «"$1" [ shape=doublecircle label="" style=filled fillcolor=black width=0.25 ]»)
m4_define(«FINAL_STATE», «FINAL_NODE($1)»)
m4_define(«ARTIFACT», «"$1" [ shape=box label=<artifact<br/>\N> ]»)

m4_define(«MODULE», «
    m4_define(«_TYPES»)
    m4_define(«_ATTRIBUTES»)
    m4_define(«_OPERATIONS»)
    m4_pushdef(«END», «
        label=<_LABEL(«\N», _TYPES, _ATTRIBUTES, _OPERATIONS)> ]
        m4_undefine(«_OPERATIONS», «_TYPES», «_ATTRIBUTES»)
        m4_popdef(«END»)
    »)
    "$1" [ margin=0 shape=folder
»)

m4_define(«PACKAGE», «
    subgraph "cluster $1" { label="$1" labeljust=r labelloc=b fontsize=_FONTSIZE
»)

MACROS
