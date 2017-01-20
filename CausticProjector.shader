// A standard projector shader with some special addons
Shader "Aaron/CausticProjector" { 
   Properties {
      _ShadowTex ("Cookie", 2D) = "gray" {} // The projected texture
      _FalloffTex ("FallOff", 2D) = "white" {} 
      _Power ("Power", Range(0,10)) = 1 // A multiplier for output
      _Size ("Size", Range(0,1)) = 1 // Tiling, basically
      _WaterHeight ("Water Height", float) = 1 // Don't project above the water
      // y = _Slope * x + b, to transform world space coordinates to projector coordinates
      _Shift ("Shift", float) = 1
      _Slope ("Slope", float) = 1
   }
   Subshader {
      Tags {"Queue"="Transparent"}

		// Test the stencil buffer so it doesn't project outside of the avatar
	  Stencil {
			Ref 1
			Comp equal
			Pass keep
		}

      Pass {
         ZWrite Off
         Fog { Color (0, 0, 0) }
         AlphaTest Greater 0
         ColorMask RGB
         Blend One One
         Offset -1, -1
 
         CGPROGRAM
         #pragma vertex vert
         #pragma fragment frag
         #include "UnityCG.cginc"
         
         struct v2f {
            float4 uvShadow : TEXCOORD0;
            float4 uvFalloff : TEXCOORD1;
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD2;
         };
         
         float4x4 _Projector;
         float4x4 _ProjectorClip;
         float _Power;
         float _Size;
         float _WaterHeight;
         float _Shift;
         float _Slope;
         
         v2f vert (float4 vertex : POSITION)
         {
            v2f o;
            o.pos = mul (UNITY_MATRIX_MVP, vertex);
            o.uvShadow  = mul (_Projector, vertex);
            o.uvFalloff = mul (_Projector, vertex);
            o.posWorld = mul(_Object2World, vertex);
            return o;
         }
         
         sampler2D _ShadowTex;
         sampler2D _FalloffTex;
         
         float4 frag (v2f i) : SV_Target
         {
            float4 texS = tex2Dproj (_ShadowTex, float4(i.uvShadow.xy,1,_Size));
 
            float4 texF = tex2Dproj (_FalloffTex, UNITY_PROJ_COORD(i.uvFalloff));
            float4 res = lerp(float4(0,0,0,0), texS, texF.a);

			// Test to see if we're above water, big conditionals like this are generally slow
            if(i.uvShadow.x < 0 || i.uvShadow.x > 1 || i.uvShadow.y < 0 || i.uvShadow.y > 1 || i.posWorld.y > _WaterHeight * _Slope + _Shift) {
               return float4(0,0,0,0);
            }

            return res * _Power;
         }
         ENDCG
      }
   }
}