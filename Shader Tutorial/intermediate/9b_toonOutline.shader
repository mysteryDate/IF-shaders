Shader "Aaron/tutorial/intermediate/9b toon outline" {
	Properties {
		_Color ("Lit Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_UnlitColor ("Unlit Color", Color) = (0.5, 0.5, 0.5, 1.0)
		_DiffuseThreshold ("Lighting Threshold", Range(-1.1,1)) = 0.1
		_Diffusion ("Diffusion", Range(0,0.99)) = 0.0
		_SpecColor ("Specular Color", Color) = (1,1,1,1)
		_Shininess ("Shininess", Range(0.5,1)) = 1
		_SpecDiffusion ("Specular Diffusion", Range(0,0.99)) = 0.0
		_OutlineColor ("Outline Color", Color) = (0, 0, 0, 1.0)
		_OutlineThickness ("Outline Thickness", Range(0,1)) = 0.1
		_OutlineDiffusion ("Outline Diffusion", Range(0,1)) = 0.0
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;
			fixed4 _UnlitColor;
			fixed _DiffuseThreshold;
			fixed _Diffusion;
			fixed4 _SpecColor;
			fixed _Shininess;
			half _SpecDiffusion;
			fixed4 _OutlineColor;
			fixed _OutlineThickness;
			fixed _OutlineDiffusion;
			
			half4 _LightColor0;
			
			struct vertexInput {
				half4 vertex : POSITION;
				half3 normal : NORMAL;
			};
			struct v2f {
				half4 pos : SV_POSITION;
				fixed3 normalDir : TEXCOORD0;
				fixed4 lightDir : TEXCOORD1;
				fixed3 viewDir : TEXCOORD2;
			};
			
			v2f vert(vertexInput v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normalDir = normalize( mul( half4(v.normal, 0.0), _World2Object).xyz );
				half4 posWorld = mul(_Object2World, v.vertex);

				o.viewDir = normalize( _WorldSpaceCameraPos.xyz - posWorld.xyz);
				half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
				o.lightDir = fixed4(
					normalize( lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w)),
					lerp(1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w)
				);

				return o;
			}
			
			fixed4 frag(v2f i) : COLOR {
				
				fixed nDotL = saturate(dot(i.normalDir, i.lightDir.xyz));

				fixed diffuseCutoff = saturate( (max(_DiffuseThreshold, nDotL) - _DiffuseThreshold ) * pow( (2-_Diffusion), 10) );
				fixed specularCutoff = saturate( max(_Shininess, dot(reflect(-i.lightDir.xyz, i.normalDir), i.viewDir)) - _Shininess ) * pow((2 - _SpecDiffusion) , 10);

				//outlines 
				fixed outlineStrength = saturate( (dot( i.normalDir, i.viewDir) - _OutlineThickness) * pow((2 - _OutlineDiffusion),10)  + _OutlineThickness); 

				fixed3 ambientLight = (1 - diffuseCutoff) * _UnlitColor.rgb;
				fixed3 diffuseReflection = (1 - specularCutoff) * _Color.rgb * diffuseCutoff;
				fixed3 specularReflection = _SpecColor.rgb * specularCutoff;
				fixed3 outlineOverlay = (_OutlineColor.rgb * (1- outlineStrength)) + outlineStrength;

				fixed3 lightFinal = (ambientLight + diffuseReflection) * outlineOverlay + specularReflection;

				return fixed4(lightFinal, 1.0);
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
