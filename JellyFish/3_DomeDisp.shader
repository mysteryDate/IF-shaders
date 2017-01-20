Shader "Aaron/JellyFish/3_DomeDisp" {
	Properties {
		_Tess ("Tessellation", Range(1,32)) = 4
		_MainTex("Color (RGB) Alpha (A)", 2D) = "white" {}
		_BumpTex("Bumpmap", 2D) = "bump" {}
		_DispTex("Disp Texutre", 2D) = "gray" {}
		_Displacement("Displacement", Range(0, 1.0)) = 0
		_Displacement2 ("Displacement 2", Range(0, 1.0)) = 0
		_RimColor("Rim Color", Color) = (0.0, 0.75, 1.0, 0.0)
		_RimPower("Rim Power", Range(0.01, 8.0)) = 1.0
		_GlowColor("Glow Color", Color) = (0.0, 0.0, 0.0, 0.0)
		_GlowPower("Glow Power", Range(0.001, 50.0)) = 50.0
		_Alpha("Alpha", Range(0.1, 8.0)) = 3
		_Offset ("Phase", Range(0, 1)) = 0
		_Offset2 ("Phase2", Range(0, 100)) = 0
		_DispPow ("DispPow", Range(0, 5)) = 0
		_Frequency ("Frequency", Range(0, 5)) = 1
		[MaterialToggle] _isReversed("Reverse", Float) = 1
	}
	SubShader {
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
		
//		Ztest always

		 // Throw out pixels that != 1 in the stencil buffer
		Stencil {
			Ref 1
			Comp equal
			Pass keep
		}

		CGPROGRAM
		#pragma surface surf Lambert alpha vertex:disp tessellate:tessFixed nolightmap
		#define PI 3.14159
//		#include "UnityStandardCore.cginc"

		struct appdata {	
			float4 vertex: POSITION;
			float3 normal: NORMAL;
			float4 tangent: TANGENT;
			float2 texcoord: TEXCOORD0;
		};

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpTex;
			float3 viewDir;
		};
		
		sampler2D _MainTex;
		sampler2D _BumpTex;
		sampler2D _DispTex;
		float _Displacement;
		float _Displacement2;
		float4 _RimColor;
		float4 _GlowColor;
		float _GlowPower;
		float _RimPower;
		float _Alpha;
		float _isReversed;
		float _Offset;
		float _Offset2;
		float _DispPow;
		float _Frequency;
		
		float _Tess;

		float4 tessFixed()
		{
			return _Tess;
		}

		void disp(inout appdata v) {
			float4 dispTex = tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0));
			float d1 = dispTex.r * _Displacement;
			float d2 = dispTex.r * _Displacement2;
			float shape = pow(dispTex.r, _DispPow * (sin(_Frequency * _Time.g + _Offset * 2 * PI) + 1));
			float2 disp1 = normalize(v.vertex.xy) * shape * _Displacement * (sin(_Frequency *  _Time.g + min(0, v.vertex.z)) + 1);
			float2 disp2 = normalize(v.vertex.xy) * d2 * (sin(30 *  _Time.g + _Offset2 * min(0, v.vertex.z)) + 1);
			v.vertex.xy += disp1 + disp2;
//			v.vertex.xy += normalize(v.vertex.xy) * pow(dispTex.r, _DispPow) * _Displacement;
		}

		void surf(Input IN, inout SurfaceOutput o) {
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			fixed4 bump = tex2D(_BumpTex, IN.uv_BumpTex);
			fixed3 myNormal;
			myNormal.xy = bump.wy * 2 - 1;
			myNormal.z = sqrt(1 - myNormal.x * myNormal.x - myNormal.y * myNormal.y);
			o.Normal = myNormal;
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
			half glow = saturate(dot(normalize(IN.viewDir), o.Normal));
			float al;
			if (_isReversed == 1) {
				al = pow(rim, 5 - _Alpha);
			} else {
				al = 1 - pow(rim, _Alpha);
			}
			o.Alpha = al;
			o.Emission = _RimColor.rgb * pow(rim, _RimPower);
		}
		ENDCG
	}
	Fallback "Diffuse"
}