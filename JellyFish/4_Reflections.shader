Shader "Aaron/JellyFish/4_Reflections" {
	Properties {
		_MainTex("Color (RGB) Alpha (A)", 2D) = "white" {}
		_Tint ("Tint", Color) = (1,1,1,1)
		_BumpTex("Bumpmap", 2D) = "bump" {}
		
		_Specular ("Specular Power", Range(0,1)) = 1
		_Gloss ("Gloss", Range(0,1)) = 1
		_Additive ("Additive", Range(0,1)) = 1
		
		_RimColor("Rim Color", Color) = (0.0, 0.75, 1.0, 0.0)
		_RimPower("Rim Power", Range(0.01, 8.0)) = 1.0
		_Alpha("Alpha", Range(0.1, 8.0)) = 3
		
		_Roughness ("Roughness", Range(0,1)) = 0
		_ReflInt ("Reflection Intensity", Range(0,2)) = 1
		_ReflFalloff ("Reflection Falloff", Range(0.01, 8.0)) = 1.0
		
		[HideInInspector] _DispTex("Disp Texture", 2D) = "gray" {}
		[HideInInspector] _Displacement("Displacement", Range(0, 0.01)) = 0
		[HideInInspector] _Offset ("Phase", Range(0, 500)) = 0
	}
	SubShader {
		Tags {
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}
	
		 // Throw out pixels that != 1 in the stencil buffer
		Stencil {
			Ref 1
			Comp equal
			Pass keep
		}

		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf SimpleSpecular alpha vertex:disp nolightmap
		#define PI 3.14159
		
		float _Foo;
		float _Bar;
		float _Additive;
		
		half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten) {
              half NdotL = max(0, dot (s.Normal, lightDir));
              atten = pow(atten, _Foo);
              half4 c;
              c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten * 2) * _Bar;
              c.a = s.Alpha;
              return c;
      	}
      	
      	half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half atten) {
	        half NdotL = dot (s.Normal, lightDir);
	        half diff = NdotL * 0.5 + 0.5;
	        atten = pow(atten, _Foo);
	        half4 c;
	        c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2) * _Bar;
	        c.a = s.Alpha;
	        return c;
	    }
	    
	    half4 LightingSimpleSpecular (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
	        half3 h = normalize (lightDir + viewDir);

	        half diff = max (0, dot (s.Normal, lightDir));

	        float nh = max (0, dot (s.Normal, h));
	        float spec = pow (nh, s.Specular*128.0) * s.Gloss;

	        half4 c;
	        c.rgb = (s.Albedo * _LightColor0.rgb * diff * _Additive + _LightColor0.rgb * spec) * (atten * 2);
	        c.a = s.Alpha;
	        return c;
	    }

		struct appdata {	
			float4 vertex: POSITION;
			float3 normal: NORMAL;
			float4 tangent: TANGENT;
			float2 texcoord: TEXCOORD0;
		};

		struct Input {
			INTERNAL_DATA
			float2 uv_MainTex;
			float2 uv_BumpTex;
			float3 viewDir;
		};
		
		sampler2D _MainTex;
		sampler2D _BumpTex;
		sampler2D _DispTex;
		float _Displacement;
		float4 _RimColor;
		float _RimPower;
		float _Alpha;
		float _Offset;

		float _Tess;
		
		float _Roughness;
		float _ReflInt;
		float _ReflFalloff;
		
		float4 _Tint;
		
		float _Gloss;
		float _Specular;

		void disp(inout appdata v) {
			float4 dispTex = tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0));
			float dTex = pow(dispTex.r, 2);
			float2 disp = normalize(v.vertex.xy) * dTex * _Displacement * (sin(30 *  _Time.g + _Offset * min(0, v.vertex.z)) + 1);
			v.vertex.xy += disp;
		}

		void surf(Input IN, inout SurfaceOutput o) {
		
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * _Tint;

			fixed4 bump = tex2D(_BumpTex, IN.uv_BumpTex);
			fixed3 myNormal;
			myNormal.xy = bump.wy * 2 - 1;
			myNormal.z = sqrt(1 - myNormal.x * myNormal.x - myNormal.y * myNormal.y);
			o.Normal = myNormal;
			
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal));
			float al = pow(rim, 5 - _Alpha);
			o.Alpha = al;
			o.Gloss = _Gloss;
			o.Specular = _Specular;
			
			float3 reflectDir = reflect(IN.viewDir, WorldNormalVector(IN, o.Normal));
			half3 env0 = Unity_GlossyEnvironment (UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, reflectDir, _Roughness);
			o.Emission += env0 * _ReflInt *  pow(rim, _ReflFalloff) + _RimColor.rgb * pow(rim, _RimPower);
			
		}
		ENDCG
	}
	Fallback "Diffuse"
}