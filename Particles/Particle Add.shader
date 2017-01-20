// Compiled shader for PC, Mac & Linux Standalone, uncompressed size: 45.5KB

// Skipping shader variants that would not be included into build of current scene.

Shader "Aaron/Particles/Additive" {
Properties {
 _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
 _MainTex ("Particle Texture", 2D) = "white" { }
 _InvFade ("Soft Particles Factor", Range(0.01,3)) = 1
}
SubShader { 
	Stencil {
				Ref 1
				Comp equal
				Pass keep
			}
 Tags { "QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }


 // Stats for Vertex shader:
 //       d3d11 : 10 avg math (5..16)
 //    d3d11_9x : 10 avg math (5..16)
 //        d3d9 : 16 avg math (6..26)
 //      opengl : 7 avg math (3..12), 1 avg texture (1..2)
 // Stats for Fragment shader:
 //       d3d11 : 6 avg math (3..10), 1 avg texture (1..2)
 //    d3d11_9x : 6 avg math (3..10), 1 avg texture (1..2)
 //        d3d9 : 9 avg math (4..14), 1 avg texture (1..2)
 Pass {
  Tags { "QUEUE"="Transparent" "IGNOREPROJECTOR"="true" "RenderType"="Transparent" }
  ZWrite Off
  Cull Off
  Blend SrcAlpha One
  AlphaTest Greater 0.01
  ColorMask RGB
  GpuProgramID 23090
Program "vp" {
SubProgram "opengl " {
// Stats: 3 math, 1 textures
Keywords { "SOFTPARTICLES_OFF" }
"!!GLSL
#ifdef VERTEX

uniform vec4 _MainTex_ST;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
void main ()
{
  gl_Position = (gl_ModelViewProjectionMatrix * gl_Vertex);
  xlv_COLOR = gl_Color;
  xlv_TEXCOORD0 = ((gl_MultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
}


#endif
#ifdef FRAGMENT
uniform sampler2D _MainTex;
uniform vec4 _TintColor;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
void main ()
{
  gl_FragData[0] = (((2.0 * xlv_COLOR) * _TintColor) * texture2D (_MainTex, xlv_TEXCOORD0));
}


#endif
"
}
SubProgram "d3d9 " {
// Stats: 6 math
Keywords { "SOFTPARTICLES_OFF" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 4 [_MainTex_ST]
"vs_2_0
dcl_position v0
dcl_color v1
dcl_texcoord v2
dp4 oPos.x, c0, v0
dp4 oPos.y, c1, v0
dp4 oPos.z, c2, v0
dp4 oPos.w, c3, v0
mad oT0.xy, v2, c4, c4.zwzw
mov oD0, v1

"
}
SubProgram "d3d11 " {
// Stats: 5 math
Keywords { "SOFTPARTICLES_OFF" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
BindCB  "$Globals" 0
BindCB  "UnityPerDraw" 1
"vs_4_0
eefiecedinkcdiknmekdjmemhibbbmndmidkfenaabaaaaaahaacaaaaadaaaaaa
cmaaaaaajmaaaaaabaabaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheo
gmaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaagcaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaafdfgfpfaepfdejfeejepeoaa
edepemepfcaafeeffiedepepfceeaaklfdeieefcfiabaaaaeaaaabaafgaaaaaa
fjaaaaaeegiocaaaaaaaaaaaaiaaaaaafjaaaaaeegiocaaaabaaaaaaaeaaaaaa
fpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaaddcbabaaa
acaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaa
gfaaaaaddccabaaaacaaaaaagiaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaa
fgbfbaaaaaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaabaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaa
aaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaaabaaaaaa
dcaaaaaldccabaaaacaaaaaaegbabaaaacaaaaaaegiacaaaaaaaaaaaahaaaaaa
ogikcaaaaaaaaaaaahaaaaaadoaaaaab"
}
SubProgram "d3d11_9x " {
// Stats: 5 math
Keywords { "SOFTPARTICLES_OFF" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
BindCB  "$Globals" 0
BindCB  "UnityPerDraw" 1
"vs_4_0_level_9_1
eefiecedbijcocimfbciilgmfpndoladengkgfbpabaaaaaaheadaaaaaeaaaaaa
daaaaaaadaabaaaajaacaaaaaaadaaaaebgpgodjpiaaaaaapiaaaaaaaaacpopp
liaaaaaaeaaaaaaaacaaceaaaaaadmaaaaaadmaaaaaaceaaabaadmaaaaaaahaa
abaaabaaaaaaaaaaabaaaaaaaeaaacaaaaaaaaaaaaaaaaaaaaacpoppbpaaaaac
afaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjabpaaaaacafaaaciaacaaapja
aeaaaaaeabaaadoaacaaoejaabaaoekaabaaookaafaaaaadaaaaapiaaaaaffja
adaaoekaaeaaaaaeaaaaapiaacaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapia
aeaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaapiaafaaoekaaaaappjaaaaaoeia
aeaaaaaeaaaaadmaaaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeia
abaaaaacaaaaapoaabaaoejappppaaaafdeieefcfiabaaaaeaaaabaafgaaaaaa
fjaaaaaeegiocaaaaaaaaaaaaiaaaaaafjaaaaaeegiocaaaabaaaaaaaeaaaaaa
fpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaaddcbabaaa
acaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaa
gfaaaaaddccabaaaacaaaaaagiaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaa
fgbfbaaaaaaaaaaaegiocaaaabaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaabaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaabaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaakpccabaaaaaaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaa
aaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaaabaaaaaa
dcaaaaaldccabaaaacaaaaaaegbabaaaacaaaaaaegiacaaaaaaaaaaaahaaaaaa
ogikcaaaaaaaaaaaahaaaaaadoaaaaabejfdeheogiaaaaaaadaaaaaaaiaaaaaa
faaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
acaaaaaaadadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaa
epfdeheogmaaaaaaadaaaaaaaiaaaaaafaaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaa
gcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaafdfgfpfaepfdejfe
ejepeoaaedepemepfcaafeeffiedepepfceeaakl"
}
SubProgram "opengl " {
// Stats: 10 math, 2 textures
Keywords { "SOFTPARTICLES_ON" }
"!!GLSL
#ifdef VERTEX
uniform vec4 _ProjectionParams;


uniform vec4 _MainTex_ST;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
varying vec4 xlv_TEXCOORD2;
void main ()
{
  vec4 tmpvar_1;
  vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * gl_Vertex);
  vec4 o_3;
  vec4 tmpvar_4;
  tmpvar_4 = (tmpvar_2 * 0.5);
  vec2 tmpvar_5;
  tmpvar_5.x = tmpvar_4.x;
  tmpvar_5.y = (tmpvar_4.y * _ProjectionParams.x);
  o_3.xy = (tmpvar_5 + tmpvar_4.w);
  o_3.zw = tmpvar_2.zw;
  tmpvar_1.xyw = o_3.xyw;
  tmpvar_1.z = -((gl_ModelViewMatrix * gl_Vertex).z);
  gl_Position = tmpvar_2;
  xlv_COLOR = gl_Color;
  xlv_TEXCOORD0 = ((gl_MultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD2 = tmpvar_1;
}


#endif
#ifdef FRAGMENT
uniform vec4 _ZBufferParams;
uniform sampler2D _MainTex;
uniform vec4 _TintColor;
uniform sampler2D _CameraDepthTexture;
uniform float _InvFade;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
varying vec4 xlv_TEXCOORD2;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = xlv_COLOR.xyz;
  tmpvar_1.w = (xlv_COLOR.w * clamp ((_InvFade * 
    ((1.0/(((_ZBufferParams.z * texture2DProj (_CameraDepthTexture, xlv_TEXCOORD2).x) + _ZBufferParams.w))) - xlv_TEXCOORD2.z)
  ), 0.0, 1.0));
  gl_FragData[0] = (((2.0 * tmpvar_1) * _TintColor) * texture2D (_MainTex, xlv_TEXCOORD0));
}


#endif
"
}
SubProgram "d3d9 " {
// Stats: 13 math
Keywords { "SOFTPARTICLES_ON" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 4 [glstate_matrix_modelview0] 3
Matrix 0 [glstate_matrix_mvp]
Vector 9 [_MainTex_ST]
Vector 7 [_ProjectionParams]
Vector 8 [_ScreenParams]
"vs_2_0
def c10, 0.5, 0, 0, 0
dcl_position v0
dcl_color v1
dcl_texcoord v2
dp4 oPos.z, c2, v0
dp4 r0.y, c1, v0
mul r0.z, r0.y, c7.x
dp4 r0.x, c0, v0
dp4 r0.w, c3, v0
mul r1.xzw, r0.xywz, c10.x
mov oPos.xyw, r0
mov oT2.w, r0.w
mad oT2.xy, r1.z, c8.zwzw, r1.xwzw
dp4 r0.x, c6, v0
mov oT2.z, -r0.x
mad oT0.xy, v2, c9, c9.zwzw
mov oD0, v1

"
}
SubProgram "d3d11 " {
// Stats: 13 math
Keywords { "SOFTPARTICLES_ON" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerCamera" 144
Vector 80 [_ProjectionParams]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
Matrix 64 [glstate_matrix_modelview0]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
BindCB  "UnityPerDraw" 2
"vs_4_0
eefiecedphocimllbfjjompcencmfdebfcbdoenhabaaaaaaoaadaaaaadaaaaaa
cmaaaaaajmaaaaaaciabaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheo
ieaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaahkaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaahkaaaaaaacaaaaaaaaaaaaaa
adaaaaaaadaaaaaaapaaaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeef
fiedepepfceeaaklfdeieefclaacaaaaeaaaabaakmaaaaaafjaaaaaeegiocaaa
aaaaaaaaaiaaaaaafjaaaaaeegiocaaaabaaaaaaagaaaaaafjaaaaaeegiocaaa
acaaaaaaaiaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaa
fpaaaaaddcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaad
pccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadpccabaaaadaaaaaa
giaaaaacacaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaa
acaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaaaaaaaaa
agbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
acaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaacaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaa
dgaaaaafpccabaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaaabaaaaaa
egbobaaaabaaaaaadcaaaaaldccabaaaacaaaaaaegbabaaaacaaaaaaegiacaaa
aaaaaaaaahaaaaaaogikcaaaaaaaaaaaahaaaaaadiaaaaaiccaabaaaaaaaaaaa
bkaabaaaaaaaaaaaakiacaaaabaaaaaaafaaaaaadiaaaaakncaabaaaabaaaaaa
agahbaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaaaaaaaaaadpaaaaaadpdgaaaaaf
iccabaaaadaaaaaadkaabaaaaaaaaaaaaaaaaaahdccabaaaadaaaaaakgakbaaa
abaaaaaamgaabaaaabaaaaaadiaaaaaibcaabaaaaaaaaaaabkbabaaaaaaaaaaa
ckiacaaaacaaaaaaafaaaaaadcaaaaakbcaabaaaaaaaaaaackiacaaaacaaaaaa
aeaaaaaaakbabaaaaaaaaaaaakaabaaaaaaaaaaadcaaaaakbcaabaaaaaaaaaaa
ckiacaaaacaaaaaaagaaaaaackbabaaaaaaaaaaaakaabaaaaaaaaaaadcaaaaak
bcaabaaaaaaaaaaackiacaaaacaaaaaaahaaaaaadkbabaaaaaaaaaaaakaabaaa
aaaaaaaadgaaaaageccabaaaadaaaaaaakaabaiaebaaaaaaaaaaaaaadoaaaaab
"
}
SubProgram "d3d11_9x " {
// Stats: 13 math
Keywords { "SOFTPARTICLES_ON" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerCamera" 144
Vector 80 [_ProjectionParams]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
Matrix 64 [glstate_matrix_modelview0]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
BindCB  "UnityPerDraw" 2
"vs_4_0_level_9_1
eefiecedjniicnkeggpcpolkkhkfgdedchjdfilnabaaaaaakmafaaaaaeaaaaaa
daaaaaaapiabaaaalaaeaaaacaafaaaaebgpgodjmaabaaaamaabaaaaaaacpopp
heabaaaaemaaaaaaadaaceaaaaaaeiaaaaaaeiaaaaaaceaaabaaeiaaaaaaahaa
abaaabaaaaaaaaaaabaaafaaabaaacaaaaaaaaaaacaaaaaaaiaaadaaaaaaaaaa
aaaaaaaaaaacpoppfbaaaaafalaaapkaaaaaaadpaaaaaaaaaaaaaaaaaaaaaaaa
bpaaaaacafaaaaiaaaaaapjabpaaaaacafaaabiaabaaapjabpaaaaacafaaacia
acaaapjaafaaaaadaaaaapiaaaaaffjaaeaaoekaaeaaaaaeaaaaapiaadaaoeka
aaaaaajaaaaaoeiaaeaaaaaeaaaaapiaafaaoekaaaaakkjaaaaaoeiaaeaaaaae
aaaaapiaagaaoekaaaaappjaaaaaoeiaafaaaaadabaaabiaaaaaffiaacaaaaka
afaaaaadabaaaiiaabaaaaiaalaaaakaafaaaaadabaaafiaaaaapeiaalaaaaka
acaaaaadacaaadoaabaakkiaabaaomiaafaaaaadabaaabiaaaaaffjaaiaakkka
aeaaaaaeabaaabiaahaakkkaaaaaaajaabaaaaiaaeaaaaaeabaaabiaajaakkka
aaaakkjaabaaaaiaaeaaaaaeabaaabiaakaakkkaaaaappjaabaaaaiaabaaaaac
acaaaeoaabaaaaibaeaaaaaeabaaadoaacaaoejaabaaoekaabaaookaaeaaaaae
aaaaadmaaaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiaabaaaaac
acaaaioaaaaappiaabaaaaacaaaaapoaabaaoejappppaaaafdeieefclaacaaaa
eaaaabaakmaaaaaafjaaaaaeegiocaaaaaaaaaaaaiaaaaaafjaaaaaeegiocaaa
abaaaaaaagaaaaaafjaaaaaeegiocaaaacaaaaaaaiaaaaaafpaaaaadpcbabaaa
aaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaaddcbabaaaacaaaaaaghaaaaae
pccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaagfaaaaaddccabaaa
acaaaaaagfaaaaadpccabaaaadaaaaaagiaaaaacacaaaaaadiaaaaaipcaabaaa
aaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaacaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaa
dcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaa
egaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaa
pgbpbaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaaaaaaaaaaegaobaaa
aaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaaabaaaaaadcaaaaaldccabaaa
acaaaaaaegbabaaaacaaaaaaegiacaaaaaaaaaaaahaaaaaaogikcaaaaaaaaaaa
ahaaaaaadiaaaaaiccaabaaaaaaaaaaabkaabaaaaaaaaaaaakiacaaaabaaaaaa
afaaaaaadiaaaaakncaabaaaabaaaaaaagahbaaaaaaaaaaaaceaaaaaaaaaaadp
aaaaaaaaaaaaaadpaaaaaadpdgaaaaaficcabaaaadaaaaaadkaabaaaaaaaaaaa
aaaaaaahdccabaaaadaaaaaakgakbaaaabaaaaaamgaabaaaabaaaaaadiaaaaai
bcaabaaaaaaaaaaabkbabaaaaaaaaaaackiacaaaacaaaaaaafaaaaaadcaaaaak
bcaabaaaaaaaaaaackiacaaaacaaaaaaaeaaaaaaakbabaaaaaaaaaaaakaabaaa
aaaaaaaadcaaaaakbcaabaaaaaaaaaaackiacaaaacaaaaaaagaaaaaackbabaaa
aaaaaaaaakaabaaaaaaaaaaadcaaaaakbcaabaaaaaaaaaaackiacaaaacaaaaaa
ahaaaaaadkbabaaaaaaaaaaaakaabaaaaaaaaaaadgaaaaageccabaaaadaaaaaa
akaabaiaebaaaaaaaaaaaaaadoaaaaabejfdeheogiaaaaaaadaaaaaaaiaaaaaa
faaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
acaaaaaaadadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaa
epfdeheoieaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaa
aaaaaaaaapaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaa
hkaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaahkaaaaaaacaaaaaa
aaaaaaaaadaaaaaaadaaaaaaapaaaaaafdfgfpfaepfdejfeejepeoaaedepemep
fcaafeeffiedepepfceeaakl"
}
SubProgram "opengl " {
// Stats: 5 math, 1 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
"!!GLSL
#ifdef VERTEX

uniform vec4 unity_FogParams;
uniform vec4 _MainTex_ST;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
varying float xlv_TEXCOORD1;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1 = (gl_ModelViewProjectionMatrix * gl_Vertex);
  float tmpvar_2;
  tmpvar_2 = (unity_FogParams.x * tmpvar_1.z);
  gl_Position = tmpvar_1;
  xlv_COLOR = gl_Color;
  xlv_TEXCOORD0 = ((gl_MultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = exp2((-(tmpvar_2) * tmpvar_2));
}


#endif
#ifdef FRAGMENT
uniform sampler2D _MainTex;
uniform vec4 _TintColor;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
varying float xlv_TEXCOORD1;
void main ()
{
  vec4 col_1;
  vec4 tmpvar_2;
  tmpvar_2 = (((2.0 * xlv_COLOR) * _TintColor) * texture2D (_MainTex, xlv_TEXCOORD0));
  col_1.w = tmpvar_2.w;
  col_1.xyz = mix (vec3(0.0, 0.0, 0.0), tmpvar_2.xyz, vec3(clamp (xlv_TEXCOORD1, 0.0, 1.0)));
  gl_FragData[0] = col_1;
}


#endif
"
}
SubProgram "d3d9 " {
// Stats: 19 math
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 0 [glstate_matrix_mvp]
Vector 5 [_MainTex_ST]
Vector 4 [unity_FogParams]
"vs_2_0
dcl_position v0
dcl_color v1
dcl_texcoord v2
dp4 oPos.x, c0, v0
dp4 oPos.y, c1, v0
dp4 oPos.w, c3, v0
mad oT0.xy, v2, c5, c5.zwzw
dp4 r0.x, c2, v0
mul r0.y, r0.x, c4.x
mov oPos.z, r0.x
mul r0.x, r0.y, -r0.y
exp oT1.x, r0.x
mov oD0, v1

"
}
SubProgram "d3d11 " {
// Stats: 8 math
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
ConstBuffer "UnityFog" 32
Vector 16 [unity_FogParams]
BindCB  "$Globals" 0
BindCB  "UnityPerDraw" 1
BindCB  "UnityFog" 2
"vs_4_0
eefiecedibilldodgboedlicbcilgpgnejadimlgabaaaaaaamadaaaaadaaaaaa
cmaaaaaajmaaaaaaciabaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheo
ieaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaahkaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaahkaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaaealaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeef
fiedepepfceeaaklfdeieefcnmabaaaaeaaaabaahhaaaaaafjaaaaaeegiocaaa
aaaaaaaaaiaaaaaafjaaaaaeegiocaaaabaaaaaaaeaaaaaafjaaaaaeegiocaaa
acaaaaaaacaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaa
fpaaaaaddcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaad
pccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadeccabaaaacaaaaaa
giaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaa
abaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaabaaaaaaaaaaaaaa
agbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
abaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaa
dgaaaaafpccabaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaaibcaabaaaaaaaaaaa
ckaabaaaaaaaaaaaakiacaaaacaaaaaaabaaaaaadiaaaaaibcaabaaaaaaaaaaa
akaabaaaaaaaaaaaakaabaiaebaaaaaaaaaaaaaabjaaaaafeccabaaaacaaaaaa
akaabaaaaaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaaabaaaaaadcaaaaal
dccabaaaacaaaaaaegbabaaaacaaaaaaegiacaaaaaaaaaaaahaaaaaaogikcaaa
aaaaaaaaahaaaaaadoaaaaab"
}
SubProgram "d3d11_9x " {
// Stats: 8 math
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
ConstBuffer "UnityFog" 32
Vector 16 [unity_FogParams]
BindCB  "$Globals" 0
BindCB  "UnityPerDraw" 1
BindCB  "UnityFog" 2
"vs_4_0_level_9_1
eefiecedkcckeimnkplhoallkmjkgbeodeiceobmabaaaaaaeiaeaaaaaeaaaaaa
daaaaaaagiabaaaaemadaaaalmadaaaaebgpgodjdaabaaaadaabaaaaaaacpopp
oeaaaaaaemaaaaaaadaaceaaaaaaeiaaaaaaeiaaaaaaceaaabaaeiaaaaaaahaa
abaaabaaaaaaaaaaabaaaaaaaeaaacaaaaaaaaaaacaaabaaabaaagaaaaaaaaaa
aaaaaaaaaaacpoppbpaaaaacafaaaaiaaaaaapjabpaaaaacafaaabiaabaaapja
bpaaaaacafaaaciaacaaapjaaeaaaaaeabaaadoaacaaoejaabaaoekaabaaooka
afaaaaadaaaaapiaaaaaffjaadaaoekaaeaaaaaeaaaaapiaacaaoekaaaaaaaja
aaaaoeiaaeaaaaaeaaaaapiaaeaaoekaaaaakkjaaaaaoeiaaeaaaaaeaaaaapia
afaaoekaaaaappjaaaaaoeiaafaaaaadabaaabiaaaaakkiaagaaaakaafaaaaad
abaaabiaabaaaaiaabaaaaibaoaaaaacabaaaeoaabaaaaiaaeaaaaaeaaaaadma
aaaappiaaaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiaabaaaaacaaaaapoa
abaaoejappppaaaafdeieefcnmabaaaaeaaaabaahhaaaaaafjaaaaaeegiocaaa
aaaaaaaaaiaaaaaafjaaaaaeegiocaaaabaaaaaaaeaaaaaafjaaaaaeegiocaaa
acaaaaaaacaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaa
fpaaaaaddcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaad
pccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaadeccabaaaacaaaaaa
giaaaaacabaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaa
abaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaabaaaaaaaaaaaaaa
agbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaa
abaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaa
aaaaaaaaegiocaaaabaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaa
dgaaaaafpccabaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaaibcaabaaaaaaaaaaa
ckaabaaaaaaaaaaaakiacaaaacaaaaaaabaaaaaadiaaaaaibcaabaaaaaaaaaaa
akaabaaaaaaaaaaaakaabaiaebaaaaaaaaaaaaaabjaaaaafeccabaaaacaaaaaa
akaabaaaaaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaaabaaaaaadcaaaaal
dccabaaaacaaaaaaegbabaaaacaaaaaaegiacaaaaaaaaaaaahaaaaaaogikcaaa
aaaaaaaaahaaaaaadoaaaaabejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheo
ieaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaahkaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaahkaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaaealaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeef
fiedepepfceeaakl"
}
SubProgram "opengl " {
// Stats: 12 math, 2 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
"!!GLSL
#ifdef VERTEX
uniform vec4 _ProjectionParams;


uniform vec4 unity_FogParams;
uniform vec4 _MainTex_ST;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
varying float xlv_TEXCOORD1;
varying vec4 xlv_TEXCOORD2;
void main ()
{
  vec4 tmpvar_1;
  vec4 tmpvar_2;
  tmpvar_2 = (gl_ModelViewProjectionMatrix * gl_Vertex);
  vec4 o_3;
  vec4 tmpvar_4;
  tmpvar_4 = (tmpvar_2 * 0.5);
  vec2 tmpvar_5;
  tmpvar_5.x = tmpvar_4.x;
  tmpvar_5.y = (tmpvar_4.y * _ProjectionParams.x);
  o_3.xy = (tmpvar_5 + tmpvar_4.w);
  o_3.zw = tmpvar_2.zw;
  tmpvar_1.xyw = o_3.xyw;
  tmpvar_1.z = -((gl_ModelViewMatrix * gl_Vertex).z);
  float tmpvar_6;
  tmpvar_6 = (unity_FogParams.x * tmpvar_2.z);
  gl_Position = tmpvar_2;
  xlv_COLOR = gl_Color;
  xlv_TEXCOORD0 = ((gl_MultiTexCoord0.xy * _MainTex_ST.xy) + _MainTex_ST.zw);
  xlv_TEXCOORD1 = exp2((-(tmpvar_6) * tmpvar_6));
  xlv_TEXCOORD2 = tmpvar_1;
}


#endif
#ifdef FRAGMENT
uniform vec4 _ZBufferParams;
uniform sampler2D _MainTex;
uniform vec4 _TintColor;
uniform sampler2D _CameraDepthTexture;
uniform float _InvFade;
varying vec4 xlv_COLOR;
varying vec2 xlv_TEXCOORD0;
varying float xlv_TEXCOORD1;
varying vec4 xlv_TEXCOORD2;
void main ()
{
  vec4 tmpvar_1;
  tmpvar_1.xyz = xlv_COLOR.xyz;
  vec4 col_2;
  tmpvar_1.w = (xlv_COLOR.w * clamp ((_InvFade * 
    ((1.0/(((_ZBufferParams.z * texture2DProj (_CameraDepthTexture, xlv_TEXCOORD2).x) + _ZBufferParams.w))) - xlv_TEXCOORD2.z)
  ), 0.0, 1.0));
  vec4 tmpvar_3;
  tmpvar_3 = (((2.0 * tmpvar_1) * _TintColor) * texture2D (_MainTex, xlv_TEXCOORD0));
  col_2.w = tmpvar_3.w;
  col_2.xyz = mix (vec3(0.0, 0.0, 0.0), tmpvar_3.xyz, vec3(clamp (xlv_TEXCOORD1, 0.0, 1.0)));
  gl_FragData[0] = col_2;
}


#endif
"
}
SubProgram "d3d9 " {
// Stats: 26 math
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
Matrix 4 [glstate_matrix_modelview0] 3
Matrix 0 [glstate_matrix_mvp]
Vector 10 [_MainTex_ST]
Vector 7 [_ProjectionParams]
Vector 8 [_ScreenParams]
Vector 9 [unity_FogParams]
"vs_2_0
def c11, 0.5, 0, 0, 0
dcl_position v0
dcl_color v1
dcl_texcoord v2
dp4 r0.y, c1, v0
mul r1.x, r0.y, c7.x
mul r1.w, r1.x, c11.x
dp4 r0.x, c0, v0
dp4 r0.w, c3, v0
mul r1.xz, r0.xyww, c11.x
mad oT2.xy, r1.z, c8.zwzw, r1.xwzw
dp4 r1.x, c6, v0
mov oT2.z, -r1.x
mad oT0.xy, v2, c10, c10.zwzw
dp4 r0.z, c2, v0
mul r1.x, r0.z, c9.x
mov oPos, r0
mov oT2.w, r0.w
mul r0.x, r1.x, -r1.x
exp oT1.x, r0.x
mov oD0, v1

"
}
SubProgram "d3d11 " {
// Stats: 16 math
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerCamera" 144
Vector 80 [_ProjectionParams]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
Matrix 64 [glstate_matrix_modelview0]
ConstBuffer "UnityFog" 32
Vector 16 [unity_FogParams]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
BindCB  "UnityPerDraw" 2
BindCB  "UnityFog" 3
"vs_4_0
eefiecedjmalkjffbgekdfolipgnododijjdmaajabaaaaaagiaeaaaaadaaaaaa
cmaaaaaajmaaaaaaeaabaaaaejfdeheogiaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaafjaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaepfdeheo
jmaaaaaaafaaaaaaaiaaaaaaiaaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaaimaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapaaaaaajcaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaajcaaaaaaabaaaaaaaaaaaaaa
adaaaaaaacaaaaaaaealaaaajcaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaa
apaaaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaakl
fdeieefccaadaaaaeaaaabaamiaaaaaafjaaaaaeegiocaaaaaaaaaaaaiaaaaaa
fjaaaaaeegiocaaaabaaaaaaagaaaaaafjaaaaaeegiocaaaacaaaaaaaiaaaaaa
fjaaaaaeegiocaaaadaaaaaaacaaaaaafpaaaaadpcbabaaaaaaaaaaafpaaaaad
pcbabaaaabaaaaaafpaaaaaddcbabaaaacaaaaaaghaaaaaepccabaaaaaaaaaaa
abaaaaaagfaaaaadpccabaaaabaaaaaagfaaaaaddccabaaaacaaaaaagfaaaaad
eccabaaaacaaaaaagfaaaaadpccabaaaadaaaaaagiaaaaacacaaaaaadiaaaaai
pcaabaaaaaaaaaaafgbfbaaaaaaaaaaaegiocaaaacaaaaaaabaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaacaaaaaaaaaaaaaaagbabaaaaaaaaaaaegaobaaa
aaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaaacaaaaaakgbkbaaa
aaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaa
adaaaaaapgbpbaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaaaaaaaaaa
egaobaaaaaaaaaaadgaaaaafpccabaaaabaaaaaaegbobaaaabaaaaaadiaaaaai
ecaabaaaaaaaaaaackaabaaaaaaaaaaaakiacaaaadaaaaaaabaaaaaadiaaaaai
ecaabaaaaaaaaaaackaabaaaaaaaaaaackaabaiaebaaaaaaaaaaaaaabjaaaaaf
eccabaaaacaaaaaackaabaaaaaaaaaaadcaaaaaldccabaaaacaaaaaaegbabaaa
acaaaaaaegiacaaaaaaaaaaaahaaaaaaogikcaaaaaaaaaaaahaaaaaadiaaaaai
ccaabaaaaaaaaaaabkaabaaaaaaaaaaaakiacaaaabaaaaaaafaaaaaadiaaaaak
ncaabaaaabaaaaaaagahbaaaaaaaaaaaaceaaaaaaaaaaadpaaaaaaaaaaaaaadp
aaaaaadpdgaaaaaficcabaaaadaaaaaadkaabaaaaaaaaaaaaaaaaaahdccabaaa
adaaaaaakgakbaaaabaaaaaamgaabaaaabaaaaaadiaaaaaibcaabaaaaaaaaaaa
bkbabaaaaaaaaaaackiacaaaacaaaaaaafaaaaaadcaaaaakbcaabaaaaaaaaaaa
ckiacaaaacaaaaaaaeaaaaaaakbabaaaaaaaaaaaakaabaaaaaaaaaaadcaaaaak
bcaabaaaaaaaaaaackiacaaaacaaaaaaagaaaaaackbabaaaaaaaaaaaakaabaaa
aaaaaaaadcaaaaakbcaabaaaaaaaaaaackiacaaaacaaaaaaahaaaaaadkbabaaa
aaaaaaaaakaabaaaaaaaaaaadgaaaaageccabaaaadaaaaaaakaabaiaebaaaaaa
aaaaaaaadoaaaaab"
}
SubProgram "d3d11_9x " {
// Stats: 16 math
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
Bind "vertex" Vertex
Bind "color" Color
Bind "texcoord" TexCoord0
ConstBuffer "$Globals" 144
Vector 112 [_MainTex_ST]
ConstBuffer "UnityPerCamera" 144
Vector 80 [_ProjectionParams]
ConstBuffer "UnityPerDraw" 336
Matrix 0 [glstate_matrix_mvp]
Matrix 64 [glstate_matrix_modelview0]
ConstBuffer "UnityFog" 32
Vector 16 [unity_FogParams]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
BindCB  "UnityPerDraw" 2
BindCB  "UnityFog" 3
"vs_4_0_level_9_1
eefiecedbbjinlhcbndokoapagekafgaaknmdbhoabaaaaaagmagaaaaaeaaaaaa
daaaaaaadaacaaaafiafaaaamiafaaaaebgpgodjpiabaaaapiabaaaaaaacpopp
kaabaaaafiaaaaaaaeaaceaaaaaafeaaaaaafeaaaaaaceaaabaafeaaaaaaahaa
abaaabaaaaaaaaaaabaaafaaabaaacaaaaaaaaaaacaaaaaaaiaaadaaaaaaaaaa
adaaabaaabaaalaaaaaaaaaaaaaaaaaaaaacpoppfbaaaaafamaaapkaaaaaaadp
aaaaaaaaaaaaaaaaaaaaaaaabpaaaaacafaaaaiaaaaaapjabpaaaaacafaaabia
abaaapjabpaaaaacafaaaciaacaaapjaafaaaaadaaaaapiaaaaaffjaaeaaoeka
aeaaaaaeaaaaapiaadaaoekaaaaaaajaaaaaoeiaaeaaaaaeaaaaapiaafaaoeka
aaaakkjaaaaaoeiaaeaaaaaeaaaaapiaagaaoekaaaaappjaaaaaoeiaafaaaaad
abaaabiaaaaaffiaacaaaakaafaaaaadabaaaiiaabaaaaiaamaaaakaafaaaaad
abaaafiaaaaapeiaamaaaakaacaaaaadacaaadoaabaakkiaabaaomiaafaaaaad
abaaabiaaaaaffjaaiaakkkaaeaaaaaeabaaabiaahaakkkaaaaaaajaabaaaaia
aeaaaaaeabaaabiaajaakkkaaaaakkjaabaaaaiaaeaaaaaeabaaabiaakaakkka
aaaappjaabaaaaiaabaaaaacacaaaeoaabaaaaibaeaaaaaeabaaadoaacaaoeja
abaaoekaabaaookaafaaaaadabaaabiaaaaakkiaalaaaakaafaaaaadabaaabia
abaaaaiaabaaaaibaoaaaaacabaaaeoaabaaaaiaaeaaaaaeaaaaadmaaaaappia
aaaaoekaaaaaoeiaabaaaaacaaaaammaaaaaoeiaabaaaaacacaaaioaaaaappia
abaaaaacaaaaapoaabaaoejappppaaaafdeieefccaadaaaaeaaaabaamiaaaaaa
fjaaaaaeegiocaaaaaaaaaaaaiaaaaaafjaaaaaeegiocaaaabaaaaaaagaaaaaa
fjaaaaaeegiocaaaacaaaaaaaiaaaaaafjaaaaaeegiocaaaadaaaaaaacaaaaaa
fpaaaaadpcbabaaaaaaaaaaafpaaaaadpcbabaaaabaaaaaafpaaaaaddcbabaaa
acaaaaaaghaaaaaepccabaaaaaaaaaaaabaaaaaagfaaaaadpccabaaaabaaaaaa
gfaaaaaddccabaaaacaaaaaagfaaaaadeccabaaaacaaaaaagfaaaaadpccabaaa
adaaaaaagiaaaaacacaaaaaadiaaaaaipcaabaaaaaaaaaaafgbfbaaaaaaaaaaa
egiocaaaacaaaaaaabaaaaaadcaaaaakpcaabaaaaaaaaaaaegiocaaaacaaaaaa
aaaaaaaaagbabaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaakpcaabaaaaaaaaaaa
egiocaaaacaaaaaaacaaaaaakgbkbaaaaaaaaaaaegaobaaaaaaaaaaadcaaaaak
pcaabaaaaaaaaaaaegiocaaaacaaaaaaadaaaaaapgbpbaaaaaaaaaaaegaobaaa
aaaaaaaadgaaaaafpccabaaaaaaaaaaaegaobaaaaaaaaaaadgaaaaafpccabaaa
abaaaaaaegbobaaaabaaaaaadiaaaaaiecaabaaaaaaaaaaackaabaaaaaaaaaaa
akiacaaaadaaaaaaabaaaaaadiaaaaaiecaabaaaaaaaaaaackaabaaaaaaaaaaa
ckaabaiaebaaaaaaaaaaaaaabjaaaaafeccabaaaacaaaaaackaabaaaaaaaaaaa
dcaaaaaldccabaaaacaaaaaaegbabaaaacaaaaaaegiacaaaaaaaaaaaahaaaaaa
ogikcaaaaaaaaaaaahaaaaaadiaaaaaiccaabaaaaaaaaaaabkaabaaaaaaaaaaa
akiacaaaabaaaaaaafaaaaaadiaaaaakncaabaaaabaaaaaaagahbaaaaaaaaaaa
aceaaaaaaaaaaadpaaaaaaaaaaaaaadpaaaaaadpdgaaaaaficcabaaaadaaaaaa
dkaabaaaaaaaaaaaaaaaaaahdccabaaaadaaaaaakgakbaaaabaaaaaamgaabaaa
abaaaaaadiaaaaaibcaabaaaaaaaaaaabkbabaaaaaaaaaaackiacaaaacaaaaaa
afaaaaaadcaaaaakbcaabaaaaaaaaaaackiacaaaacaaaaaaaeaaaaaaakbabaaa
aaaaaaaaakaabaaaaaaaaaaadcaaaaakbcaabaaaaaaaaaaackiacaaaacaaaaaa
agaaaaaackbabaaaaaaaaaaaakaabaaaaaaaaaaadcaaaaakbcaabaaaaaaaaaaa
ckiacaaaacaaaaaaahaaaaaadkbabaaaaaaaaaaaakaabaaaaaaaaaaadgaaaaag
eccabaaaadaaaaaaakaabaiaebaaaaaaaaaaaaaadoaaaaabejfdeheogiaaaaaa
adaaaaaaaiaaaaaafaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapapaaaa
fjaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapapaaaafpaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaacaaaaaaadadaaaafaepfdejfeejepeoaaedepemepfcaafe
effiedepepfceeaaepfdeheojmaaaaaaafaaaaaaaiaaaaaaiaaaaaaaaaaaaaaa
abaaaaaaadaaaaaaaaaaaaaaapaaaaaaimaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaapaaaaaajcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadamaaaa
jcaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaaealaaaajcaaaaaaacaaaaaa
aaaaaaaaadaaaaaaadaaaaaaapaaaaaafdfgfpfaepfdejfeejepeoaaedepemep
fcaafeeffiedepepfceeaakl"
}
}
Program "fp" {
SubProgram "opengl " {
Keywords { "SOFTPARTICLES_OFF" }
"!!GLSL"
}
SubProgram "d3d9 " {
// Stats: 4 math, 1 textures
Keywords { "SOFTPARTICLES_OFF" }
Vector 0 [_TintColor]
SetTexture 0 [_MainTex] 2D 0
"ps_2_0
dcl v0
dcl t0.xy
dcl_2d s0
texld r0, t0, s0
mul r1, v0, c0
add r1, r1, r1
mul_pp r0, r0, r1
mov_pp oC0, r0

"
}
SubProgram "d3d11 " {
// Stats: 3 math, 1 textures
Keywords { "SOFTPARTICLES_OFF" }
SetTexture 0 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
BindCB  "$Globals" 0
"ps_4_0
eefiecedoahgkenbdekcbaipiifgmgoofcddacpcabaaaaaalmabaaaaadaaaaaa
cmaaaaaakaaaaaaaneaaaaaaejfdeheogmaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaagcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaakl
epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklklfdeieefcoaaaaaaaeaaaaaaa
diaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaafkaaaaadaagabaaaaaaaaaaa
fibiaaaeaahabaaaaaaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaad
dcbabaaaacaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaaaaaaaah
pcaabaaaaaaaaaaaegbobaaaabaaaaaaegbobaaaabaaaaaadiaaaaaipcaabaaa
aaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaagaaaaaaefaaaaajpcaabaaa
abaaaaaaegbabaaaacaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaadiaaaaah
pccabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaabaaaaaadoaaaaab"
}
SubProgram "d3d11_9x " {
// Stats: 3 math, 1 textures
Keywords { "SOFTPARTICLES_OFF" }
SetTexture 0 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
BindCB  "$Globals" 0
"ps_4_0_level_9_1
eefiecedmkfebaojlhlahiapkcocgcggllhcbiaeabaaaaaaheacaaaaaeaaaaaa
daaaaaaaoeaaaaaammabaaaaeaacaaaaebgpgodjkmaaaaaakmaaaaaaaaacpppp
hiaaaaaadeaaaaaaabaaciaaaaaadeaaaaaadeaaabaaceaaaaaadeaaaaaaaaaa
aaaaagaaabaaaaaaaaaaaaaaaaacppppbpaaaaacaaaaaaiaaaaaaplabpaaaaac
aaaaaaiaabaaadlabpaaaaacaaaaaajaaaaiapkaecaaaaadaaaaapiaabaaoela
aaaioekaafaaaaadabaaapiaaaaaoelaaaaaoekaacaaaaadabaaapiaabaaoeia
abaaoeiaafaaaaadaaaacpiaaaaaoeiaabaaoeiaabaaaaacaaaicpiaaaaaoeia
ppppaaaafdeieefcoaaaaaaaeaaaaaaadiaaaaaafjaaaaaeegiocaaaaaaaaaaa
ahaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaa
gcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagfaaaaadpccabaaa
aaaaaaaagiaaaaacacaaaaaaaaaaaaahpcaabaaaaaaaaaaaegbobaaaabaaaaaa
egbobaaaabaaaaaadiaaaaaipcaabaaaaaaaaaaaegaobaaaaaaaaaaaegiocaaa
aaaaaaaaagaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaaacaaaaaaeghobaaa
aaaaaaaaaagabaaaaaaaaaaadiaaaaahpccabaaaaaaaaaaaegaobaaaaaaaaaaa
egaobaaaabaaaaaadoaaaaabejfdeheogmaaaaaaadaaaaaaaiaaaaaafaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaafmaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaagcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaakl
epfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
aaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}
SubProgram "opengl " {
Keywords { "SOFTPARTICLES_ON" }
"!!GLSL"
}
SubProgram "d3d9 " {
// Stats: 12 math, 2 textures
Keywords { "SOFTPARTICLES_ON" }
Float 2 [_InvFade]
Vector 1 [_TintColor]
Vector 0 [_ZBufferParams]
SetTexture 0 [_MainTex] 2D 0
SetTexture 1 [_CameraDepthTexture] 2D 1
"ps_2_0
def c3, 2, 0, 0, 0
dcl v0
dcl t0.xy
dcl t2
dcl_2d s0
dcl_2d s1
texldp r0, t2, s1
texld r1, t0, s0
mad r0.x, c0.z, r0.x, c0.w
rcp r0.x, r0.x
add r0.x, r0.x, -t2.z
mul_sat r0.x, r0.x, c2.x
mul_pp r0.x, r0.x, v0.w
mul r0.x, r0.x, c3.x
mul r0.w, r0.x, c1.w
mov r2.xyz, v0
mul r2.xyz, r2, c1
mul r0.xyz, r2, c3.x
mul_pp r0, r1, r0
mov_pp oC0, r0

"
}
SubProgram "d3d11 " {
// Stats: 9 math, 2 textures
Keywords { "SOFTPARTICLES_ON" }
SetTexture 0 [_CameraDepthTexture] 2D 1
SetTexture 1 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
Float 128 [_InvFade]
ConstBuffer "UnityPerCamera" 144
Vector 112 [_ZBufferParams]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
"ps_4_0
eefiecedbfgpcddacplclnjndefffmbppiifpigkabaaaaaabaadaaaaadaaaaaa
cmaaaaaaliaaaaaaomaaaaaaejfdeheoieaaaaaaaeaaaaaaaiaaaaaagiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaheaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaahkaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaahkaaaaaaacaaaaaaaaaaaaaaadaaaaaaadaaaaaaapapaaaafdfgfpfa
epfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaklepfdeheocmaaaaaa
abaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaa
fdfgfpfegbhcghgfheaaklklfdeieefcbmacaaaaeaaaaaaaihaaaaaafjaaaaae
egiocaaaaaaaaaaaajaaaaaafjaaaaaeegiocaaaabaaaaaaaiaaaaaafkaaaaad
aagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaafibiaaaeaahabaaaaaaaaaaa
ffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaa
gcbaaaaddcbabaaaacaaaaaagcbaaaadpcbabaaaadaaaaaagfaaaaadpccabaaa
aaaaaaaagiaaaaacacaaaaaaaoaaaaahdcaabaaaaaaaaaaaegbabaaaadaaaaaa
pgbpbaaaadaaaaaaefaaaaajpcaabaaaaaaaaaaaegaabaaaaaaaaaaaeghobaaa
aaaaaaaaaagabaaaabaaaaaadcaaaaalbcaabaaaaaaaaaaackiacaaaabaaaaaa
ahaaaaaaakaabaaaaaaaaaaadkiacaaaabaaaaaaahaaaaaaaoaaaaakbcaabaaa
aaaaaaaaaceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaiadpakaabaaaaaaaaaaa
aaaaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaackbabaiaebaaaaaaadaaaaaa
dicaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaaakiacaaaaaaaaaaaaiaaaaaa
diaaaaahicaabaaaaaaaaaaaakaabaaaaaaaaaaadkbabaaaabaaaaaadgaaaaaf
hcaabaaaaaaaaaaaegbcbaaaabaaaaaaaaaaaaahpcaabaaaaaaaaaaaegaobaaa
aaaaaaaaegaobaaaaaaaaaaadiaaaaaipcaabaaaaaaaaaaaegaobaaaaaaaaaaa
egiocaaaaaaaaaaaagaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaaacaaaaaa
eghobaaaabaaaaaaaagabaaaaaaaaaaadiaaaaahpccabaaaaaaaaaaaegaobaaa
aaaaaaaaegaobaaaabaaaaaadoaaaaab"
}
SubProgram "d3d11_9x " {
// Stats: 9 math, 2 textures
Keywords { "SOFTPARTICLES_ON" }
SetTexture 0 [_CameraDepthTexture] 2D 1
SetTexture 1 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
Float 128 [_InvFade]
ConstBuffer "UnityPerCamera" 144
Vector 112 [_ZBufferParams]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
"ps_4_0_level_9_1
eefiecedhcplfjcdaidkhiaibekikifdkjognikjabaaaaaalmaeaaaaaeaaaaaa
daaaaaaaniabaaaapmadaaaaiiaeaaaaebgpgodjkaabaaaakaabaaaaaaacpppp
faabaaaafaaaaaaaadaacmaaaaaafaaaaaaafaaaacaaceaaaaaafaaaabaaaaaa
aaababaaaaaaagaaabaaaaaaaaaaaaaaaaaaaiaaabaaabaaaaaaaaaaabaaahaa
abaaacaaaaaaaaaaaaacppppfbaaaaafadaaapkaaaaaaaeaaaaaaaaaaaaaaaaa
aaaaaaaabpaaaaacaaaaaaiaaaaaaplabpaaaaacaaaaaaiaabaaadlabpaaaaac
aaaaaaiaacaaaplabpaaaaacaaaaaajaaaaiapkabpaaaaacaaaaaajaabaiapka
agaaaaacaaaaaiiaacaapplaafaaaaadaaaaadiaaaaappiaacaaoelaecaaaaad
aaaaapiaaaaaoeiaabaioekaecaaaaadabaaapiaabaaoelaaaaioekaaeaaaaae
aaaaabiaacaakkkaaaaaaaiaacaappkaagaaaaacaaaaabiaaaaaaaiaacaaaaad
aaaaabiaaaaaaaiaacaakklbafaaaaadaaaabbiaaaaaaaiaabaaaakaafaaaaad
aaaacbiaaaaaaaiaaaaapplaafaaaaadaaaaabiaaaaaaaiaadaaaakaafaaaaad
aaaaaiiaaaaaaaiaaaaappkaabaaaaacacaaahiaaaaaoelaafaaaaadacaaahia
acaaoeiaaaaaoekaafaaaaadaaaaahiaacaaoeiaadaaaakaafaaaaadaaaacpia
abaaoeiaaaaaoeiaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefcbmacaaaa
eaaaaaaaihaaaaaafjaaaaaeegiocaaaaaaaaaaaajaaaaaafjaaaaaeegiocaaa
abaaaaaaaiaaaaaafkaaaaadaagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaa
fibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaa
gcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagcbaaaadpcbabaaa
adaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaaoaaaaahdcaabaaa
aaaaaaaaegbabaaaadaaaaaapgbpbaaaadaaaaaaefaaaaajpcaabaaaaaaaaaaa
egaabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaabaaaaaadcaaaaalbcaabaaa
aaaaaaaackiacaaaabaaaaaaahaaaaaaakaabaaaaaaaaaaadkiacaaaabaaaaaa
ahaaaaaaaoaaaaakbcaabaaaaaaaaaaaaceaaaaaaaaaiadpaaaaiadpaaaaiadp
aaaaiadpakaabaaaaaaaaaaaaaaaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaa
ckbabaiaebaaaaaaadaaaaaadicaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaa
akiacaaaaaaaaaaaaiaaaaaadiaaaaahicaabaaaaaaaaaaaakaabaaaaaaaaaaa
dkbabaaaabaaaaaadgaaaaafhcaabaaaaaaaaaaaegbcbaaaabaaaaaaaaaaaaah
pcaabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaaipcaabaaa
aaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaagaaaaaaefaaaaajpcaabaaa
abaaaaaaegbabaaaacaaaaaaeghobaaaabaaaaaaaagabaaaaaaaaaaadiaaaaah
pccabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaabaaaaaadoaaaaabejfdeheo
ieaaaaaaaeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaa
apaaaaaaheaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapapaaaahkaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadadaaaahkaaaaaaacaaaaaaaaaaaaaa
adaaaaaaadaaaaaaapapaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeef
fiedepepfceeaaklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}
SubProgram "opengl " {
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
"!!GLSL"
}
SubProgram "d3d9 " {
// Stats: 6 math, 1 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
Vector 0 [_TintColor]
SetTexture 0 [_MainTex] 2D 0
"ps_2_0
dcl v0
dcl t0.xy
dcl t1.x
dcl_2d s0
texld r0, t0, s0
mul r1, v0, c0
add r1, r1, r1
mul_pp r0, r0, r1
mov_sat r1.x, t1.x
mul_pp r0.xyz, r0, r1.x
mov_pp oC0, r0

"
}
SubProgram "d3d11 " {
// Stats: 4 math, 1 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
SetTexture 0 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
BindCB  "$Globals" 0
"ps_4_0
eefiecedfkmgoejaohankfdoppacecilipjfdljeabaaaaaaceacaaaaadaaaaaa
cmaaaaaaliaaaaaaomaaaaaaejfdeheoieaaaaaaaeaaaaaaaiaaaaaagiaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaheaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaahkaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaahkaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaaeaeaaaafdfgfpfa
epfdejfeejepeoaaedepemepfcaafeeffiedepepfceeaaklepfdeheocmaaaaaa
abaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaa
fdfgfpfegbhcghgfheaaklklfdeieefcdaabaaaaeaaaaaaaemaaaaaafjaaaaae
egiocaaaaaaaaaaaahaaaaaafkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaa
aaaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaa
gcbaaaadecbabaaaacaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaa
aaaaaaahpcaabaaaaaaaaaaaegbobaaaabaaaaaaegbobaaaabaaaaaadiaaaaai
pcaabaaaaaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaagaaaaaaefaaaaaj
pcaabaaaabaaaaaaegbabaaaacaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaa
diaaaaahpcaabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaabaaaaaadgcaaaaf
bcaabaaaabaaaaaackbabaaaacaaaaaadiaaaaahhccabaaaaaaaaaaaegacbaaa
aaaaaaaaagaabaaaabaaaaaadgaaaaaficcabaaaaaaaaaaadkaabaaaaaaaaaaa
doaaaaab"
}
SubProgram "d3d11_9x " {
// Stats: 4 math, 1 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_OFF" }
SetTexture 0 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
BindCB  "$Globals" 0
"ps_4_0_level_9_1
eefiecedldhodbcfgpdabgmkondnaekpphhggkkdabaaaaaapiacaaaaaeaaaaaa
daaaaaaaaaabaaaadiacaaaameacaaaaebgpgodjmiaaaaaamiaaaaaaaaacpppp
jeaaaaaadeaaaaaaabaaciaaaaaadeaaaaaadeaaabaaceaaaaaadeaaaaaaaaaa
aaaaagaaabaaaaaaaaaaaaaaaaacppppbpaaaaacaaaaaaiaaaaaaplabpaaaaac
aaaaaaiaabaaahlabpaaaaacaaaaaajaaaaiapkaecaaaaadaaaaapiaabaaoela
aaaioekaafaaaaadabaaapiaaaaaoelaaaaaoekaacaaaaadabaaapiaabaaoeia
abaaoeiaafaaaaadaaaacpiaaaaaoeiaabaaoeiaabaaaaacabaabbiaabaakkla
afaaaaadaaaachiaaaaaoeiaabaaaaiaabaaaaacaaaicpiaaaaaoeiappppaaaa
fdeieefcdaabaaaaeaaaaaaaemaaaaaafjaaaaaeegiocaaaaaaaaaaaahaaaaaa
fkaaaaadaagabaaaaaaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaagcbaaaad
pcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagcbaaaadecbabaaaacaaaaaa
gfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaaaaaaaaahpcaabaaaaaaaaaaa
egbobaaaabaaaaaaegbobaaaabaaaaaadiaaaaaipcaabaaaaaaaaaaaegaobaaa
aaaaaaaaegiocaaaaaaaaaaaagaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaa
acaaaaaaeghobaaaaaaaaaaaaagabaaaaaaaaaaadiaaaaahpcaabaaaaaaaaaaa
egaobaaaaaaaaaaaegaobaaaabaaaaaadgcaaaafbcaabaaaabaaaaaackbabaaa
acaaaaaadiaaaaahhccabaaaaaaaaaaaegacbaaaaaaaaaaaagaabaaaabaaaaaa
dgaaaaaficcabaaaaaaaaaaadkaabaaaaaaaaaaadoaaaaabejfdeheoieaaaaaa
aeaaaaaaaiaaaaaagiaaaaaaaaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaa
heaaaaaaaaaaaaaaaaaaaaaaadaaaaaaabaaaaaaapapaaaahkaaaaaaaaaaaaaa
aaaaaaaaadaaaaaaacaaaaaaadadaaaahkaaaaaaabaaaaaaaaaaaaaaadaaaaaa
acaaaaaaaeaeaaaafdfgfpfaepfdejfeejepeoaaedepemepfcaafeeffiedepep
fceeaaklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl"
}
SubProgram "opengl " {
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
"!!GLSL"
}
SubProgram "d3d9 " {
// Stats: 14 math, 2 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
Float 2 [_InvFade]
Vector 1 [_TintColor]
Vector 0 [_ZBufferParams]
SetTexture 0 [_MainTex] 2D 0
SetTexture 1 [_CameraDepthTexture] 2D 1
"ps_2_0
def c3, 2, 0, 0, 0
dcl v0
dcl t0.xy
dcl t1.x
dcl t2
dcl_2d s0
dcl_2d s1
texldp r0, t2, s1
texld r1, t0, s0
mad r0.x, c0.z, r0.x, c0.w
rcp r0.x, r0.x
add r0.x, r0.x, -t2.z
mul_sat r0.x, r0.x, c2.x
mul_pp r0.x, r0.x, v0.w
mul r0.x, r0.x, c3.x
mul r0.w, r0.x, c1.w
mov r2.xyz, v0
mul r2.xyz, r2, c1
mul r0.xyz, r2, c3.x
mul_pp r0, r1, r0
mov_sat r1.x, t1.x
mul_pp r0.xyz, r0, r1.x
mov_pp oC0, r0

"
}
SubProgram "d3d11 " {
// Stats: 10 math, 2 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
SetTexture 0 [_CameraDepthTexture] 2D 1
SetTexture 1 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
Float 128 [_InvFade]
ConstBuffer "UnityPerCamera" 144
Vector 112 [_ZBufferParams]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
"ps_4_0
eefieceddgjcnimpdkicbbllgikijbpjeppeofglabaaaaaahiadaaaaadaaaaaa
cmaaaaaanaaaaaaaaeabaaaaejfdeheojmaaaaaaafaaaaaaaiaaaaaaiaaaaaaa
aaaaaaaaabaaaaaaadaaaaaaaaaaaaaaapaaaaaaimaaaaaaaaaaaaaaaaaaaaaa
adaaaaaaabaaaaaaapapaaaajcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaa
adadaaaajcaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaaeaeaaaajcaaaaaa
acaaaaaaaaaaaaaaadaaaaaaadaaaaaaapapaaaafdfgfpfaepfdejfeejepeoaa
edepemepfcaafeeffiedepepfceeaaklepfdeheocmaaaaaaabaaaaaaaiaaaaaa
caaaaaaaaaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgf
heaaklklfdeieefcgmacaaaaeaaaaaaajlaaaaaafjaaaaaeegiocaaaaaaaaaaa
ajaaaaaafjaaaaaeegiocaaaabaaaaaaaiaaaaaafkaaaaadaagabaaaaaaaaaaa
fkaaaaadaagabaaaabaaaaaafibiaaaeaahabaaaaaaaaaaaffffaaaafibiaaae
aahabaaaabaaaaaaffffaaaagcbaaaadpcbabaaaabaaaaaagcbaaaaddcbabaaa
acaaaaaagcbaaaadecbabaaaacaaaaaagcbaaaadpcbabaaaadaaaaaagfaaaaad
pccabaaaaaaaaaaagiaaaaacacaaaaaaaoaaaaahdcaabaaaaaaaaaaaegbabaaa
adaaaaaapgbpbaaaadaaaaaaefaaaaajpcaabaaaaaaaaaaaegaabaaaaaaaaaaa
eghobaaaaaaaaaaaaagabaaaabaaaaaadcaaaaalbcaabaaaaaaaaaaackiacaaa
abaaaaaaahaaaaaaakaabaaaaaaaaaaadkiacaaaabaaaaaaahaaaaaaaoaaaaak
bcaabaaaaaaaaaaaaceaaaaaaaaaiadpaaaaiadpaaaaiadpaaaaiadpakaabaaa
aaaaaaaaaaaaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaackbabaiaebaaaaaa
adaaaaaadicaaaaibcaabaaaaaaaaaaaakaabaaaaaaaaaaaakiacaaaaaaaaaaa
aiaaaaaadiaaaaahicaabaaaaaaaaaaaakaabaaaaaaaaaaadkbabaaaabaaaaaa
dgaaaaafhcaabaaaaaaaaaaaegbcbaaaabaaaaaaaaaaaaahpcaabaaaaaaaaaaa
egaobaaaaaaaaaaaegaobaaaaaaaaaaadiaaaaaipcaabaaaaaaaaaaaegaobaaa
aaaaaaaaegiocaaaaaaaaaaaagaaaaaaefaaaaajpcaabaaaabaaaaaaegbabaaa
acaaaaaaeghobaaaabaaaaaaaagabaaaaaaaaaaadiaaaaahpcaabaaaaaaaaaaa
egaobaaaaaaaaaaaegaobaaaabaaaaaadgcaaaafbcaabaaaabaaaaaackbabaaa
acaaaaaadiaaaaahhccabaaaaaaaaaaaegacbaaaaaaaaaaaagaabaaaabaaaaaa
dgaaaaaficcabaaaaaaaaaaadkaabaaaaaaaaaaadoaaaaab"
}
SubProgram "d3d11_9x " {
// Stats: 10 math, 2 textures
Keywords { "FOG_EXP2" "SOFTPARTICLES_ON" }
SetTexture 0 [_CameraDepthTexture] 2D 1
SetTexture 1 [_MainTex] 2D 0
ConstBuffer "$Globals" 144
Vector 96 [_TintColor]
Float 128 [_InvFade]
ConstBuffer "UnityPerCamera" 144
Vector 112 [_ZBufferParams]
BindCB  "$Globals" 0
BindCB  "UnityPerCamera" 1
"ps_4_0_level_9_1
eefiecedlnikkoaghebdhjhalmhnfeomheegcageabaaaaaaeaafaaaaaeaaaaaa
daaaaaaapeabaaaagiaeaaaaamafaaaaebgpgodjlmabaaaalmabaaaaaaacpppp
gmabaaaafaaaaaaaadaacmaaaaaafaaaaaaafaaaacaaceaaaaaafaaaabaaaaaa
aaababaaaaaaagaaabaaaaaaaaaaaaaaaaaaaiaaabaaabaaaaaaaaaaabaaahaa
abaaacaaaaaaaaaaaaacppppfbaaaaafadaaapkaaaaaaaeaaaaaaaaaaaaaaaaa
aaaaaaaabpaaaaacaaaaaaiaaaaaaplabpaaaaacaaaaaaiaabaaahlabpaaaaac
aaaaaaiaacaaaplabpaaaaacaaaaaajaaaaiapkabpaaaaacaaaaaajaabaiapka
agaaaaacaaaaaiiaacaapplaafaaaaadaaaaadiaaaaappiaacaaoelaecaaaaad
aaaaapiaaaaaoeiaabaioekaecaaaaadabaaapiaabaaoelaaaaioekaaeaaaaae
aaaaabiaacaakkkaaaaaaaiaacaappkaagaaaaacaaaaabiaaaaaaaiaacaaaaad
aaaaabiaaaaaaaiaacaakklbafaaaaadaaaabbiaaaaaaaiaabaaaakaafaaaaad
aaaacbiaaaaaaaiaaaaapplaafaaaaadaaaaabiaaaaaaaiaadaaaakaafaaaaad
aaaaaiiaaaaaaaiaaaaappkaabaaaaacacaaahiaaaaaoelaafaaaaadacaaahia
acaaoeiaaaaaoekaafaaaaadaaaaahiaacaaoeiaadaaaakaafaaaaadaaaacpia
abaaoeiaaaaaoeiaabaaaaacabaabbiaabaakklaafaaaaadaaaachiaaaaaoeia
abaaaaiaabaaaaacaaaicpiaaaaaoeiappppaaaafdeieefcgmacaaaaeaaaaaaa
jlaaaaaafjaaaaaeegiocaaaaaaaaaaaajaaaaaafjaaaaaeegiocaaaabaaaaaa
aiaaaaaafkaaaaadaagabaaaaaaaaaaafkaaaaadaagabaaaabaaaaaafibiaaae
aahabaaaaaaaaaaaffffaaaafibiaaaeaahabaaaabaaaaaaffffaaaagcbaaaad
pcbabaaaabaaaaaagcbaaaaddcbabaaaacaaaaaagcbaaaadecbabaaaacaaaaaa
gcbaaaadpcbabaaaadaaaaaagfaaaaadpccabaaaaaaaaaaagiaaaaacacaaaaaa
aoaaaaahdcaabaaaaaaaaaaaegbabaaaadaaaaaapgbpbaaaadaaaaaaefaaaaaj
pcaabaaaaaaaaaaaegaabaaaaaaaaaaaeghobaaaaaaaaaaaaagabaaaabaaaaaa
dcaaaaalbcaabaaaaaaaaaaackiacaaaabaaaaaaahaaaaaaakaabaaaaaaaaaaa
dkiacaaaabaaaaaaahaaaaaaaoaaaaakbcaabaaaaaaaaaaaaceaaaaaaaaaiadp
aaaaiadpaaaaiadpaaaaiadpakaabaaaaaaaaaaaaaaaaaaibcaabaaaaaaaaaaa
akaabaaaaaaaaaaackbabaiaebaaaaaaadaaaaaadicaaaaibcaabaaaaaaaaaaa
akaabaaaaaaaaaaaakiacaaaaaaaaaaaaiaaaaaadiaaaaahicaabaaaaaaaaaaa
akaabaaaaaaaaaaadkbabaaaabaaaaaadgaaaaafhcaabaaaaaaaaaaaegbcbaaa
abaaaaaaaaaaaaahpcaabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaaaaaaaaa
diaaaaaipcaabaaaaaaaaaaaegaobaaaaaaaaaaaegiocaaaaaaaaaaaagaaaaaa
efaaaaajpcaabaaaabaaaaaaegbabaaaacaaaaaaeghobaaaabaaaaaaaagabaaa
aaaaaaaadiaaaaahpcaabaaaaaaaaaaaegaobaaaaaaaaaaaegaobaaaabaaaaaa
dgcaaaafbcaabaaaabaaaaaackbabaaaacaaaaaadiaaaaahhccabaaaaaaaaaaa
egacbaaaaaaaaaaaagaabaaaabaaaaaadgaaaaaficcabaaaaaaaaaaadkaabaaa
aaaaaaaadoaaaaabejfdeheojmaaaaaaafaaaaaaaiaaaaaaiaaaaaaaaaaaaaaa
abaaaaaaadaaaaaaaaaaaaaaapaaaaaaimaaaaaaaaaaaaaaaaaaaaaaadaaaaaa
abaaaaaaapapaaaajcaaaaaaaaaaaaaaaaaaaaaaadaaaaaaacaaaaaaadadaaaa
jcaaaaaaabaaaaaaaaaaaaaaadaaaaaaacaaaaaaaeaeaaaajcaaaaaaacaaaaaa
aaaaaaaaadaaaaaaadaaaaaaapapaaaafdfgfpfaepfdejfeejepeoaaedepemep
fcaafeeffiedepepfceeaaklepfdeheocmaaaaaaabaaaaaaaiaaaaaacaaaaaaa
aaaaaaaaaaaaaaaaadaaaaaaaaaaaaaaapaaaaaafdfgfpfegbhcghgfheaaklkl
"
}
}
 }
}
}