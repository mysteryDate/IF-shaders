Shader "Karl/HideGhost"{ 
    Properties {
      _MainTex ("Color (RGB) Alpha (A)", 2D) = "white" {}
      _BumpTex ("Bumpmap", 2D) = "bump" {}
      _GRimColor ("Rim Color", Color) = (0.0,0.75,1.0,0.0)
      _GRimPower ("Rim Power", Range(0.01,8.0)) = 1.0
      _GlowColor ("Glow Color", Color) = (0.0,0.0,0.0,0.0)
      _GlowPower ("Glow Power", Range(0.001,50.0)) = 50.0
      _Alpha ("Alpha", Range(0.1,8.0)) = 3
      [MaterialToggle] _isReversed("Reverse", Float) = 1
    }
    SubShader {
      Tags { "Queue"="Transparent" "RenderType"="Transparent" }
      
	  Cull Back
	  ZTest GEqual
      CGPROGRAM
      #pragma surface surf Lambert alpha 
      struct Input {
          float2 uv_MainTex;
          float2 uv_BumpTex;
          float3 viewDir;
      };
      sampler2D _MainTex;
      sampler2D _BumpTex;
      float4 _GRimColor;
      float4 _GlowColor;
      float _GlowPower;
      float _GRimPower;
      float _Alpha;
      float _isReversed;
	  
      void surf (Input IN, inout SurfaceOutput o) {
		o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
		fixed4 bump = tex2D(_BumpTex, IN.uv_BumpTex);
		fixed3 myNormal;
		myNormal.xy = bump.wy * 2 - 1;
	    myNormal.z = sqrt(1 - myNormal.x*myNormal.x - myNormal.y * myNormal.y);
		o.Normal = myNormal;
		half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
		half glow = saturate(dot (normalize(IN.viewDir), o.Normal));
		float al;
		if(_isReversed == 1) {
			al = pow (rim, 5 - _Alpha);
		}
		else {
			al = 1 - pow (rim, _Alpha);
		}
		o.Alpha = al;
		o.Emission =  _GRimColor.rgb * pow (rim, _GRimPower) + _GlowColor.rgb * pow(glow, _GlowPower);
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }