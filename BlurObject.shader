// This shader adds a blur to an object
// It should generally be applied as a second material
// We blur horizontally then vertically as separate passes, which is standard procedure [ O(n^2) -> O(2n) complexity ]
// If this is used a lot with a particular material, its passes should be added to that materials shader (less expensive that way)
Shader "Aaron/BlurObject" {
   Properties {
        _BlurSize ("Blur Amount", Range(0, 40)) = 1
        // How far the blur blends into the texture, proportunal to how "blurry" it looks
        _Extend ("Extrusion Size", Range(0, .5)) = .01
        // Extrudes the mesh along its normals to blur the background as well, works better on meshes with smoother geometries
    }
   
    Category {
   
        // We must be transparent, so other objects are drawn before this one.
        // We can render opaque because of the grabpasses
        Tags { "Queue"="Overlay" "IgnoreProjector"="True" "RenderType"="Transparent" }
   		ZWrite Off
   		ZTest Always
   		
        SubShader {

            // Horizontal blur
            GrabPass { "_GrabTex"// Grabs the current frame, puts it into _GrabTex                   
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
                sampler2D _GrabTex;
                float4 _GrabTex_TexelSize;
                float _BlurSize;
                float _Extend;
                
               
               struct appdata_t {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord: TEXCOORD0;
                };
               
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                };
               
                v2f vert (appdata_t v) {
                    v2f o;
                    // Normal vertex computation, plus an extrusion along the normals
                    o.vertex = mul(UNITY_MATRIX_MVP, v.vertex) + _Extend*normalize(mul(UNITY_MATRIX_MVP, float4(v.normal, 0.0)));
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
                    return o;
                }
               
                
               
                half4 frag( v2f i ) : COLOR {
                   
                    half4 sum = half4(0,0,0,0);
 
                    #define GRABPIXEL(weight,kernelx) tex2Dproj( _GrabTex, UNITY_PROJ_COORD(float4(i.uvgrab.x + _GrabTex_TexelSize.x * kernelx * _BlurSize, i.uvgrab.y, i.uvgrab.z, i.uvgrab.w))) * weight
                    
                    //G(X) = (1/(sqrt(2*PI*deviation*deviation))) * exp(-(x*x / (2*deviation*deviation)))
                    // Normal distribution mofos!
 
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.18,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
                   
                    return float4(sum);
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
                sampler2D _GrabTexture;
                float4 _GrabTexture_TexelSize;
                float _BlurSize;
                float _Extend;
                
               
               struct appdata_t {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord: TEXCOORD0;
                };
               
                struct v2f {
                    float4 vertex : POSITION;
                    float4 uvgrab : TEXCOORD0;
                };
               
                v2f vert (appdata_t v) {
                    v2f o;
                    // Normal vertex computation, plus an extrusion along the normals
                    o.vertex = mul(UNITY_MATRIX_MVP, v.vertex) + _Extend*normalize(mul(UNITY_MATRIX_MVP, float4(v.normal, 0.0)));
                    #if UNITY_UV_STARTS_AT_TOP
                    float scale = -1.0;
                    #else
                    float scale = 1.0;
                    #endif
                    o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
                    o.uvgrab.zw = o.vertex.zw;
                    return o;
                }
               
                
               
                half4 frag( v2f i ) : COLOR {
                   
                    half4 sum = half4(0,0,0,0);
 
                    #define GRABPIXEL(weight,kernely) tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(float4(i.uvgrab.x, i.uvgrab.y + _GrabTexture_TexelSize.y * kernely * _BlurSize, i.uvgrab.z, i.uvgrab.w))) * weight
                    
                    //G(X) = (1/(sqrt(2*PI*deviation*deviation))) * exp(-(x*x / (2*deviation*deviation)))
                    // Normal distribution mofos!
 
                    sum += GRABPIXEL(0.05, -4.0);
                    sum += GRABPIXEL(0.09, -3.0);
                    sum += GRABPIXEL(0.12, -2.0);
                    sum += GRABPIXEL(0.15, -1.0);
                    sum += GRABPIXEL(0.18,  0.0);
                    sum += GRABPIXEL(0.15, +1.0);
                    sum += GRABPIXEL(0.12, +2.0);
                    sum += GRABPIXEL(0.09, +3.0);
                    sum += GRABPIXEL(0.05, +4.0);
                   
                    return float4(sum);
                }
                ENDCG
            }
        }
    }
}