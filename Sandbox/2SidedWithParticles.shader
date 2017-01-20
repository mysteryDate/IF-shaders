Shader "Aaron/Sandbox/2SidedWithParticles" {
   Properties {
      _MainTex ("Color (RGB) Alpha (A)", 2D) = "black" {}
      _BackTex ("Back Texture", 2D) = "BlueSpace" {}
      _AlphaMask ("Alpha Mask", 2D) = "white" {}
	  _BaseAlpha ("Minimum Alpha", Range(0,1)) = 0.2
	  _AlphaCutoff ("Back Alpha", Range(0,1)) = 0
	  _FrontAlpha ("Front Alpha", Range(0, 1)) = 1
	  [MaterialToggle] _SharpCutoff("Sharp Cutoff", Float) = 0
      
   }
   SubShader {
      Tags { "Queue"= "Transparent" "RenderType" = "Transparent" } 
         // draw after all opaque geometry has been drawn
      Pass {
         Cull Front // first pass renders only back faces 
             // (the "inside")
         Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
         ZWrite On // write to the depth buffer, since this side is opaque
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         // Variables
         uniform sampler2D _BackTex;
         uniform sampler2D _BumpTex;
         uniform sampler2D _AlphaMask;
         float _AlphaCutoff;
         

         //base input structs
         struct vertexInput {
            float4 vertex : POSITION;
            float4 texcoord : TEXCOORD0;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 tex : TEXCOORD0;
         };

         // vertex function
         vertexOutput vert(vertexInput v){
            vertexOutput o;
            
            o.tex = v.texcoord;
            o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
            return o;
         }


         // Fragment function
         float4 frag(vertexOutput i) : COLOR 
         {
            float4 tex = tex2D(_BackTex, i.tex.xy);
            
            return float4(tex.rgb, _AlphaCutoff);
         } 
 
         ENDCG  
      }
      Pass {
      	Cull Back
      	Zwrite On
      	ColorMask 0
      }

   }
   Fallback "Diffuse"
}

