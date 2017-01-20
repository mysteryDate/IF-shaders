// Innerworld terrain, based on the bumpedSpecular SSS shader
// There is a special version of SSS.cginc in the shaders folder that this utilizes
// The only new feature to this shader is that it blends between two textures
Shader "Aaron/IWTerrain" {
	Properties 
	{
		[V_MaterialTag]
		_V_MaterialTag("", float) = 0

		//Default Options
		[V_MaterialTitle]
		_V_MaterialTitle_Default("Default Options", float) = 0


		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125
		_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}		
		_SecondTex ("Secondary Texture", 2D) = "white" {}
		_BumpSize("Bump Size", float) = 1
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_SecondBump ("Secondary Bumpmap", 2D) = "bump" {}
		
		[HideInInspector] _LayerMask ("LayerMask", 2D) = "black" {}
		_MaskPower ("Blend Amount", float) = 1
		
		//Default Options
		[V_MaterialTitle]
		_V_MaterialTitle_SSS("Translucency Options", float) = 0

		_TransDistortion ("Transluceny Distortion",Range(0,0.5)) = 0.1
		_TransPower("Translucency Power",Range(1.0,16.0)) = 1.0
		_TransScale("Translucency Scale", Float) = 1.0
		_TransColor ("Translucency Color", color) = (1, 1, 1, 1)
		_TransMap ("Translucency Map",2D) = "white" {}
		_SecondTransColor ("Secondary Translucency Color", color) = (1,1,1,1)
		_SecondTransMap ("Secondary Translucency Map", 2D) = "white" {}
		_TransBackfaceIntensity("Backface Intensity", Float) = 0.15

		[V_MaterialTitle]
		_V_MaterialTitle_SSS("Additional Lighting Options", float) = 0
		_TransDirectianalLightStrength("Directional Light Strength", Range(0.0, 1.0)) = 0.2
		_TransOtherLightsStrength("Point/Spot Light Strength", Range(0.0, 1.0)) = 0.5
		_V_SSS_Emission("Emission", Float) = 0

		_V_SSS_Rim_Color("Rim Color", color) = (1, 1, 1, 1)
		_V_SSS_Rim_Pow("Rim Power", Range(0.5, 8.0)) = 2.0
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" "SSSType"="Legacy/PixelLit"}
		LOD 400
		
		CGPROGRAM
		#pragma surface surf2 TransBlinnPhong nodynlightmap

		#pragma shader_feature V_SSS_NORMALIZE_DIFFUSE_COEF_OFF V_SSS_NORMALIZE_DIFFUSE_COEF_ON
		#pragma shader_feature V_SSS_ADVANCED_TRANSLUSENCY_OFF V_SSS_ADVANCED_TRANSLUSENCY_ON
		#pragma shader_feature V_SSS_RIM_OFF V_SSS_RIM_ON

		#ifdef V_SSS_RIM_ON
		#pragma target 3.0
		#endif

		#define V_SSS_SPECULAR
		#define V_SSS_BUMPED
		#define V_SSS_TWO_TEXTURES

		#include "SSS.cginc" 

		
		void surf2 (Input IN, inout TransSurfaceOutput o)
		{
			half4 maskTex = tex2D(_LayerMask, half2(1 - IN.worldPos.z,IN.worldPos.x)/128);
			half4 tex = tex2D(_MainTex, IN.uv_MainTex);
			half4 tex2 = tex2D(_SecondTex, IN.uv_SecondTex);
			// A sigmoid function for blending the two textures
			float mix = 1/(1 + pow(2.718, -1*_MaskPower*(maskTex.r - 0.5)));
			o.Albedo = ( (1-mix)*tex.rgb + mix*tex2) * _Color.rgb;
			o.Alpha = tex.a * _Color.a;

			#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON
				fixed3 transCol1 = tex2D(_TransMap,IN.uv_MainTex).rgb * _TransColor.rgb;
				fixed3 transCol2 = tex2D(_SecondTransMap,IN.uv_SecondTex).rgb * _SecondTransColor.rgb;
				o.TransCol = ( (1-mix)*transCol1 + mix*transCol2 ) ;
			#endif

			#ifdef V_SSS_SPECULAR
				o.Gloss = tex.a * (1 - maskTex.g);
				o.Specular = _Shininess;
			#endif

			#ifdef V_SSS_BUMPED
				half3 normal1 = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
				half3 normal2 = UnpackNormal(tex2D(_SecondBump, IN.uv_SecondBump));
				o.Normal = ( (1-mix) * normal1 + mix * normal2 );
				o.Normal.x *= _BumpSize;
				o.Normal.y *= _BumpSize;
				o.Normal = normalize(o.Normal);
			#endif
			
			o.Emission += o.Albedo * _V_SSS_Emission * o.Alpha;


			#ifdef V_SSS_RIM_ON
				half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
		        o.Emission += _V_SSS_Rim_Color.rgb * pow (rim, _V_SSS_Rim_Pow);
			#endif
		}

		ENDCG
	}

	FallBack "Specular"
//	CustomEditor "SubsurfaceScatteringMaterial_Editor"
}
