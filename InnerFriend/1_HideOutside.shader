Shader "Aaron/IF/1_HideOutside" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
	}
	SubShader {
		Tags { "Queue" = "Transparent" "RenderType"="Opaque" }
		
		Pass {
			Cull Back
			ZTest GEqual
			
			CGPROGRAM
			
			#pragma vertex v2f
			#pragma fragment frag
			
			//Variables
			sampler2D _MainTex;
			sampler2D _BumpMap;
			
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			
			struct vertexOutput {
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
				float4 tex : TEXCOORD2;
				float3 tangentDir : TEXCOORD3;
            	float3 binormalDir: TEXCOORD4;
			};
			
			// Vertex function
			vertexOutput v2f(vertexInput v) {
				vertexOutput o;
				
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
	            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
    	        o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
        	    
            	o.posWorld = mul(_Object2World, v.vertex);
	            o.tex = v.texcoord;
    	        o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
        	    return o;
			}
			
			// Fragment function
			float4 frag(vertexOutput i) : COLOR {
			
				float4 texN = tex2D(_BumpMap, i.tex.xy);
	            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);

        	    float3x3 local2WorldTranspose = float3x3(
            	   i.tangentDir,
    	           i.binormalDir,
	               i.normalDir);

        	    float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));

            	float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
            	
            	float rim = (1 - dot(normalize(viewDirection), normalDirection));
            	
//            	float4 finalColor = _RimColor * pow(rim, _RimPower);
            	
            	float4 tex = tex2D(_MainTex, i.tex.xy);
            	
            	return tex;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
