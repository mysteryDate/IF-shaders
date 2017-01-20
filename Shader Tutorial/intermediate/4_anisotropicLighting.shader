Shader "Aaron/tutorial/intermediate/4 Anisotropic Lighting" {
	Properties {
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_AniX ("Anisotropic X", Range(0.0, 2.0)) = 1.0
		_AniY ("Anisotropic y", Range(0.0, 2.0)) = 1.0
		_Shininess ("Shininess", Float) = 1.0
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;
			fixed4 _SpecColor;
			fixed _AniX;
			fixed _AniY;
			half _Shininess;
			
			half4 _LightColor0;
			
			struct vertexInput {
				half4 vertex : POSITION;
				half3 normal : NORMAL;
				half4 tangent : TANGENT;
			};
			struct v2f {
				half4 pos : SV_POSITION;
				fixed3 normalDir : TEXCOORD0;
				fixed4 lightDir : TEXCOORD1;
				fixed3 viewDir : TEXCOORD2;
				fixed3 tangentDir : TEXCOORD3;
			};
			
			v2f vert(vertexInput v) {
				v2f o;

				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normalDir = normalize( mul( half4(v.normal, 0.0), _World2Object).xyz );
				o.tangentDir = normalize( mul( _Object2World, half4(v.tangent.xyz, 0.0)).xyz);
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
				
				// half vector
				fixed3 h = normalize(i.lightDir.xyz + i.viewDir);
				half3 binormalDir = cross(i.normalDir, i.tangentDir);
				
				fixed nDotL = dot(i.normalDir, i.lightDir.xyz);
				fixed nDotH = dot(i.normalDir, h);
				fixed nDotV = dot(i.normalDir, i.viewDir);
				fixed tDotHX = dot(i.tangentDir, h) / _AniX;
				fixed bDotHY = dot(binormalDir, h) / _AniY;
				
				fixed3 diffuseReflection = i.lightDir.w * _LightColor0.xyz * saturate(nDotL);
				fixed3 specularReflection = i.lightDir.w * saturate(nDotL) * _SpecColor * exp( -(tDotHX * tDotHX + bDotHY * bDotHY) ) * _Shininess;

				fixed3 lightFinal =  diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz + specularReflection;

				return fixed4(lightFinal *  _Color.xyz, 1.0);
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
