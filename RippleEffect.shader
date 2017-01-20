// A procedural shader for propogating ripples
Shader "Aaron/RippleEffect" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "" {
            }
		_Spread ("Spread", float) = 1
		_Damping ("Damping", float) = 0.99
		_Waterline ("WaterLine", float) = 0
		_MainColor ("Main Color", color) = (0,0,0,0)
	}
	SubShader {
        Pass {
            ZTest Always 
			Cull Off 
			Zwrite Off
			CGPROGRAM
			// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
			#pragma exclude_renderers gles
			#include "UnityCG.cginc"
			
			//pragmas
			#pragma vertex vert
			#pragma fragment frag
			
			//user defined variables
			sampler2D _MainTex;
            sampler2D _BackBuffer;
            sampler2D _IslandsTex;
            half4 _MainTex_TexelSize;
            int _Spread;
            float _Damping;
            float3 _Point;
            float2 _UVPoint;
            float2 _UVPointSmall;
            float4 _MainColor;
            float _WaterLine;
            //base input structs
			struct vertexInput{
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            }

;
            struct vertexOutput{
                float4 pos : SV_POSITION;
                half2 tex : TEXCOORD0;
                half2 taps[4] : TEXCOORD1;
            }

;
            //vetex shader
			vertexOutput vert(vertexInput v) {
                vertexOutput o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.tex = v.texcoord.xy;
                o.taps[0] = o.tex + half2(_MainTex_TexelSize.x,0) * _Spread;
                o.taps[1] = o.tex + half2(0,_MainTex_TexelSize.y) * _Spread;
                o.taps[2] = o.tex - half2(_MainTex_TexelSize.x,0) * _Spread;
                o.taps[3] = o.tex - half2(0,_MainTex_TexelSize.y) * _Spread;
                return o;
            }



			//fragment shader	
			float4 frag(vertexOutput i) : COLOR
			{
                fixed4 shift = fixed4(0,0.6,0,0.6);
                float4 tex = tex2D(_MainTex, i.taps[0].xy);
                tex += tex2D(_MainTex, i.taps[1].xy);
                tex += tex2D(_MainTex, i.taps[2].xy);
                tex += tex2D(_MainTex, i.taps[3].xy);
                tex = tex/2 - tex2D(_BackBuffer, i.tex.xy);
                tex = _Damping * (tex - shift) + shift;
                float4 vec = tex - float4(0,0.5,0,0.5);
                float4 vec2 = normalize(vec) / 2.01;
                float len = min(length(vec), length(vec2));
                vec = normalize(vec) * len;
                tex = float4(0,0.5,0,0.5) + vec;
                if(i.tex.x < 0.01 || i.tex.x > 0.99 || i.tex.y < 0.01 || i.tex.y > 0.99) {
                    tex = float4(0,0.5,0,0.5);
                }


				
				// Click!
				float dist = distance(i.tex.xy, _UVPoint.xy);
                float distSmall = distance(i.tex.xy, _UVPointSmall.xy);
                if (dist < 0.01) {
                    tex = float4(0,0.707,0,0.707);
                    // 0.707 ~= sqrt(2)/2
                }

				else if (distSmall < 0.002) {
                    tex = float4(0,0.6,0,0.6);
                }


				
				if (i.tex.y > _WaterLine) {
                    tex = float4(0,0.5,0,0.5);
                }

				return tex;
            }


			
			ENDCG
		}
	}
//	Fallback "Diffuse"
}
