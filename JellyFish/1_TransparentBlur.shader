Shader "Aaron/JellyFish/1_TransparentBlur"{ 
   Properties {
        _BumpAmt  ("Distortion", Range (0,128)) = 10
        _MainTexture ("Main Texture", 2D) = "white" {}
        _Size ("Size", Range(0, 40)) = 1
        _Pos ("IF Position", Vector) = (0,0,0,0)
        _BumpTex ("Bumpmap", 2D) = "bump" {}
        _AlphaMask ("Alpha Mask", 2D) = "white" {}
        _FrontColor ("Front Color", Color) = (0, 0, 0.24, 0.0)
        _RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
        _RimPower ("Rim Power", Range(0,1)) = 0.5
        _BumpDepth ("BumpDepth", Range(0.2,3.0)) = 2.2
        _SpotRadius ("Spot Radius", Range(0, 10)) = 2 
        _SpotPower ("Spot Power", Range(0, 10)) = 5
        _BaseAlpha ("Minimum Alpha", Range(0,1)) = 0.2
        _MaxAlpha ("Maximum Alpha", Range(-1,1)) = 0.9   
        _GlowColor ("Glow Color", Color) = (0.0,0.0,0.0,0.0)
      	_GlowPower ("Glow Power", Range(0.001,50.0)) = 50.0
        [MaterialToggle] _IsInner ("Inner View", Float) = 0
    }
   
    Category {
   
        // We must be transparent, so other objects are drawn before this one.
        // We can render opaque because of the grabpasses
        Tags { "Queue"="Transparent+2" "IgnoreProjector"="True" "RenderType"="Transparent" }
   
        SubShader {
//       //             Transparency Layer
//            Pass {
//                Cull Back // second pass renders only front faces 
//                // (the "outside")
//                ZWrite On // Write to depth buffer to occlude particles in opaque bits
//                Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
// 
//                CGPROGRAM 
//
//                #pragma vertex vert 
//                #pragma fragment frag
//
//                // Variables
//                uniform sampler2D _MainTex;
//                uniform sampler2D _BumpTex;
//                uniform sampler2D _AlphaMask;
//                float4 _FrontColor;
//                float4 _RimColor;
//                float _RimPower;
//                float _BumpDepth;
//                float _BaseAlpha;
//                float _MaxAlpha;   
//                float _IsInner;
//                float4 _Pos;
//                float _SpotRadius;
//                float _SpotPower;
//                float _Size;
//                float4 _GlowColor;
//                float _GlowPower;
//
//                //base input structs
//                struct vertexInput {
//                    float4 vertex : POSITION;
//                    float3 normal : NORMAL;
//                    float4 texcoord : TEXCOORD0;
//                    float4 tangent : TANGENT;
//                };
//                struct vertexOutput {
//                    float4 pos : SV_POSITION;
//                    float4 posWorld : TEXCOORD0;
//                    float3 normalDir : TEXCOORD1;
//                    float4 tex : TEXCOORD2;
//                    float3 tangentDir : TEXCOORD3;
//                    float3 binormalDir: TEXCOORD4;
//                    float3 closestPoint: TEXCOORD5;
//                };
//
//                // vertex function
//                vertexOutput vert(vertexInput v){
//                    vertexOutput o;
//
//                    o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
//                    o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
//                    o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
//
//                    o.posWorld = mul(_Object2World, v.vertex);
//                    o.tex = v.texcoord;
//                    o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
//                    return o;
//                }
//
//
//                // Fragment function
//                float4 frag(vertexOutput i) : COLOR 
//                {
//                	
//                    float4 texN = tex2D(_BumpTex, i.tex.xy);
//                    float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
//                    localCoords.z = _BumpDepth;
//
//                    float3x3 local2WorldTranspose = float3x3(
//                       i.tangentDir,
//                       i.binormalDir,
//                       i.normalDir);
//
//                    float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));
//
//                    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
//
//                    float rim = (1 - dot(normalize(viewDirection), normalDirection));
//                    half glow = (dot (normalize(viewDirection), normalDirection));
//
//                    float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
//
//                    float4 finalColor = _FrontColor + _RimColor * pow(rim, _RimPower);
//
//                    float4 maskTex = tex2D(_AlphaMask, i.tex.xy);
//
//                    float dist = length( cross(i.posWorld.xyz - _Pos.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld);
//
//                    float al = pow(dist / _SpotRadius, _SpotPower);
//
//                    al = clamp(al, _BaseAlpha, _MaxAlpha);
//					
//					float4 tex = tex2D(_MainTex, i.tex.xy);
//                    return float4(_FrontColor.rgb, 0.2);
////					return float4(tex.rgb, 1);
//                } 
//                ENDCG  
//            }
            // Horizontal blur
            GrabPass {                     
                Tags { "LightMode" = "Always" }
            }
            Pass {
                Tags { "LightMode" = "Always" }
                Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
                sampler2D _GrabTexture;
                float4 _GrabTexture_TexelSize;
                float _Size;
                float4 _Pos;
                float _RimPower;
                float _MaxAlpha;
                
               
               struct appdata_t {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord: TEXCOORD0;
                };
               
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                    float4 posWorld : TEXCOORD1;
                    float3 normalDir : TEXCOORD2;
                };
               
                v2f vert (appdata_t v) {
                    v2f o;
                    o.vertex = mul(UNITY_MATRIX_MVP, v.vertex + _Size/2000*float4(v.normal, 0.0));
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
                    o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
                    o.posWorld = mul(_Object2World, v.vertex);
                    return o;
                }
               
                
               
                half4 frag( v2f i ) : COLOR {
                     float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                    float rim = 1 - saturate(dot(normalize(viewDirection), i.normalDir));
                    rim = 1 - pow(rim, _RimPower);
                   
                    half4 sum = half4(0,0,0,0);
 
                    #define GRABPIXEL(weight,kernelx) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x + _GrabTexture_TexelSize.x * kernelx * _Size, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight
 
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.18,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
                   
                    return float4(sum.rgb, _MaxAlpha * rim);
                }
                ENDCG
            }
 
            // Vertical blur
            GrabPass {                         
                Tags { "LightMode" = "Always" }
            }
            Pass {
                Tags { "LightMode" = "Always" }
                Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma fragmentoption ARB_precision_hint_fastest
                #include "UnityCG.cginc"
               
                struct appdata_t {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord: TEXCOORD0;
                };
               
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                    float4 posWorld : TEXCOORD1;
                    float3 normalDir : TEXCOORD2;
                };
                
                sampler2D _GrabTexture;
                float4 _GrabTexture_TexelSize;
                float _Size;
                float4 _Pos;
                float _MaxAlpha;
                float _RimPower;
               
                v2f vert (appdata_t v) {
                    v2f o;
                    o.vertex = mul(UNITY_MATRIX_MVP, v.vertex + _Size/2000*float4(v.normal, 0.0));
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
                    
                    o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
                    
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
                    o.posWorld = mul(_Object2World, v.vertex);
                    return o;
                }
               
                
               
                half4 frag( v2f i ) : COLOR {

                    half4 sum = half4(0,0,0,0);
                    
                    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                    float rim = 1 - saturate(dot(normalize(viewDirection), i.normalDir));
                    rim = 1 - pow(rim, _RimPower);
 
                    #define GRABPIXEL(weight,kernely) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _GrabTexture_TexelSize.y * kernely * _Size, i.uvgrab.z, i.uvgrab.w))) * weight
 
                    //G(X) = (1/(sqrt(2*PI*deviation*deviation))) * exp(-(x*x / (2*deviation*deviation)))
                   
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.18,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
                   
                    return float4(sum.rgb, _MaxAlpha * rim);
                }
                ENDCG
            }

        }
    }
}