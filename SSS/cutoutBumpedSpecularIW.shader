Shader "Aaron/SSS/cutoutBumpedSpecularIW" 
{
	Properties 
	{
		_Additive ("Additive",Range(0,1)) = 1
//		[V_MaterialTag]
//		_V_MaterialTag("", float) = 0

		//Default Options
		[V_MaterialTitle]
		_V_MaterialTitle_Default("Default Options", float) = 0


		_Color ("Main Color", Color) = (1,1,1,1)		
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 0)
		_Shininess ("Shininess", Range (0.01, 1)) = 0.078125
		_MainTex ("Base (RGB) TransGloss (A)", 2D) = "white" {}
		_BumpSize("Bump Size", float) = 1
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		
		
		//Default Options
		[V_MaterialTitle]
		_V_MaterialTitle_SSS("Translucency Options", float) = 0

		_TransMap ("Translucency Map (RGB)",2D) = "white" {}
		_TransColor ("Translucency Color (RGB)", color) = (1, 1, 1, 1)
		_TransDistortion ("Translucency Distortion",Range(0,0.5)) = 0.1
		_TransPower("Translucency Power",Range(1.0,16.0)) = 1.0
		_TransScale("Translucency Scale", Float) = 1.0
		_TransBackfaceIntensity("Backface Intensity", Float) = 0.15

		//Additional Options
		[V_MaterialTitle]
		_V_MaterialTitle_SSS("Additional Lighting Options", float) = 0
		_TransDirectianalLightStrength("Directional Light Strength", Range(0.0, 1.0)) = 0.2
		_TransOtherLightsStrength("Point/Spot Lights Strength", Range(0.0, 1.0)) = 0.5
		_V_SSS_Emission("Emission", Float) = 0

		_V_SSS_Rim_Color("Rim Color", color) = (1, 1, 1, 1)
		_V_SSS_Rim_Pow("Rim Power", Range(0.5, 8.0)) = 2.0
	}
	SubShader 
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" "SSSType"="Legacy/PixelLit"}
		LOD 400

		Cull Off
		
		CGPROGRAM
		#pragma surface surf2 TransBlinnPhong2 alphatest:_Cutoff nodynlightmap

		#pragma shader_feature V_SSS_NORMALIZE_DIFFUSE_COEF_OFF V_SSS_NORMALIZE_DIFFUSE_COEF_ON
		#pragma shader_feature V_SSS_ADVANCED_TRANSLUSENCY_OFF V_SSS_ADVANCED_TRANSLUSENCY_ON
		#pragma shader_feature V_SSS_RIM_OFF V_SSS_RIM_ON

		#ifdef V_SSS_RIM_ON
		#pragma target 3.0
		#endif

		#define V_SSS_SPECULAR
		#define V_SSS_BUMPED


		#include "SSS.cginc"
		
		float _Additive;
		
		inline fixed4 LightingTransBlinnPhong2 (TransSurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
		{	
			half atten2 = (atten * 2);

			fixed3 diffCol;
			fixed3 specCol;
			float spec;	
			
			half NL = dot (s.Normal, lightDir);
			#ifdef V_SSS_NORMALIZE_DIFFUSE_COEF_ON
				NL = max(0.0, NL);
			#endif

			half3 h = normalize (lightDir + viewDir);
			
			float nh = max (0, dot (s.Normal, h));
			spec = pow (nh, s.Specular*128.0) * s.Gloss;
			
			diffCol = (s.Albedo * _LightColor0.rgb * NL) * atten2;
			specCol = (_LightColor0.rgb * _SpecColor.rgb * spec) * atten2;

			half3 transLight = lightDir + s.Normal * _TransDistortion;
			float VinvL = saturate(dot(viewDir, -transLight));
			
			float transDot = pow(VinvL,_TransPower);
			#ifndef V_SSS_ADVANCED_TRANSLUSENCY_ON
				transDot *= _TransScale;
			#endif 

			half3 lightAtten = _LightColor0.rgb * atten2;
			#ifdef UNITY_PASS_FORWARDBASE
				lightAtten *= _TransDirectianalLightStrength;
			#else
				lightAtten *= _TransOtherLightsStrength;
			#endif

			half3 transComponent = (transDot + _Color.rgb);
			#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON	
				half3 subSurfaceComponent = s.TransCol * _TransScale;	
				transComponent = lerp(transComponent, subSurfaceComponent, transDot);		

				transComponent += (1 - NL) * s.TransCol * _LightColor0.rgb * _TransBackfaceIntensity;
			#endif

			diffCol = s.Albedo * (_LightColor0.rgb * atten2 * NL + lightAtten * transComponent);

			
			fixed4 c;
			c.rgb = diffCol + specCol * 2;
			c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
			c.rgb *=  _Additive;
			return c;
		}
		
		void surf2 (Input IN, inout TransSurfaceOutput o)
		{
			half4 tex = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = tex.rgb * _Color.rgb;
			o.Alpha = tex.a * _Color.a;

			#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON
				o.TransCol = tex2D(_TransMap,IN.uv_MainTex).rgb * _TransColor.rgb;
			#endif

			#ifdef V_SSS_SPECULAR
				o.Gloss = tex.a;
				o.Specular = _Shininess;
			#endif

			#ifdef V_SSS_BUMPED
				o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
				o.Normal.x *= _BumpSize;
				o.Normal.y *= _BumpSize;
				o.Normal = normalize(o.Normal);
			#endif

			#ifdef V_SSS_REFLECTIVE
				#ifdef V_SSS_BUMPED
					float3 worldRefl = WorldReflectionVector (IN, o.Normal);
					fixed4 reflcol = texCUBE (_Cube, worldRefl);
				#else
					fixed4 reflcol = texCUBE (_Cube, IN.worldRefl);
				#endif

				reflcol *= tex.a;
				o.Emission = reflcol.rgb * _ReflectColor.rgb;
			#endif

			
			o.Emission += o.Albedo * _V_SSS_Emission * o.Alpha;


			#ifdef V_SSS_RIM_ON
				half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
		        o.Emission += _V_SSS_Rim_Color.rgb * pow (rim, _V_SSS_Rim_Pow);
			#endif
			
		}


		ENDCG
	}

	Fallback "Transparent/Cutout/VertexLit"
//	CustomEditor "SubsurfaceScatteringMaterial_Editor"
}