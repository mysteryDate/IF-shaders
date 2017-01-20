Shader "Aaron/tutorial/intermediate/7 flat translucency" {
	Properties {
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Float) = 10.0
		_BackScatter ("Back Translucent Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Translucence ("Forward Translucent Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Intensity ("Translucent Intensity", Float) = 10.0
	}
	SubShader {
		Pass {
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			fixed4 _Color;
			fixed4 _SpecColor;
			half _Shininess;
			fixed4 _BackScatter;
			fixed4 _Translucence;
			half _Intensity;
			
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
				fixed3 diffuseReflection = i.lightDir.w * _LightColor0 * nDotL;
				fixed3 specularReflection = diffuseReflection * _SpecColor.rgb * pow(saturate(dot(reflect(-i.lightDir.xyz, i.normalDir), i.viewDir)), _Shininess);

				// translucency
				fixed3 backScatter = i.lightDir.w * _LightColor0.xyz * _BackScatter.rgb * saturate( dot(i.normalDir, -i.lightDir.xyz) );
				fixed3 translucence = i.lightDir.w * _LightColor0.xyz * _Translucence.rgb * pow( saturate( dot( -i.lightDir.xyz, i.viewDir) ), _Intensity);

				fixed3 lightFinal = translucence + backScatter + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

				return fixed4(lightFinal *  _Color.xyz, 1.0);
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
