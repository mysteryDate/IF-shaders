Shader "Aaron/tutorial/intermediate/8 Vertex Animation" {
	Properties {
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Float) = 10.0
		_AnimSpeed ("Animation Speed", Float) = 10.0	
		_AnimFreq ("Animation Frequency", Float) = 1.0	
		_AnimPowerX ("Animation Power X", Float) = 0.0	
		_AnimPowerY ("Animation Power Y", Float) = 0.1	
		_AnimPowerZ ("Animation Power Z", Float) = 0.0	
		_AnimOffsetX ("Animation Offset X", Float) = 0.0	
		_AnimOffsetY ("Animation Offset Y", Float) = 0.0	
		_AnimOffsetZ ("Animation Offset Z", Float) = 0.0	
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

			//Animation
			half _AnimSpeed;
			half _AnimFreq;
			half _AnimPowerX;
			half _AnimPowerY;
			half _AnimPowerZ;
			half _AnimOffsetX;
			half _AnimOffsetY;
			half _AnimOffsetZ;
			
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

				// animate verteces
				half3 animOffset = half3(_AnimOffsetX, _AnimOffsetY, _AnimOffsetZ) * v.vertex.xyz;
				half3 animPower = half3(_AnimPowerX, _AnimPowerY, _AnimPowerZ);
				half4 newPos = v.vertex;
				newPos.xyz = newPos.xyz + sin(_Time.x * _AnimSpeed + (animOffset.x + animOffset.y + animOffset.z) * _AnimFreq) * animPower.xyz;

				o.pos = mul(UNITY_MATRIX_MVP, newPos);
				o.normalDir = normalize( mul( half4(v.normal, 0.0), _World2Object).xyz );
				half4 posWorld = mul(_Object2World, newPos);

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

				fixed3 lightFinal = diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

				return fixed4(lightFinal *  _Color.xyz, 1.0);
			}
			
			ENDCG
		}
	}
	//Fallback "Diffuse"
}
