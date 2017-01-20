Shader "Aaron/Sandbox/OtherSideParticles" {
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
      Tags { "Queue"= "Transparent+2" "RenderType" = "Transparent" } 
         // draw after all opaque geometry has been drawn
 
      Pass {
         Cull Back // second pass renders only front faces 
             // (the "outside")
         ZWrite On // don't write to depth buffer 
            // in order not to occlude other objects
         Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         // Variables
         uniform sampler2D _MainTex;
         uniform sampler2D _AlphaMask;
         float _BaseAlpha;
         float _FrontAlpha;
         float _SharpCutoff;

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

			float4 tex = tex2D(_MainTex, i.tex.xy);
            
            float4 maskTex = tex2D(_AlphaMask, i.tex.xy);
            
            float alpha = maskTex.r / _FrontAlpha;
            
            if(_SharpCutoff == 1) {
            	if(alpha > _FrontAlpha) {
            		alpha = 1;
            	}
            	else {
            		discard;
            	}
            }

            return float4(tex.rgb, alpha);
         } 
         ENDCG  
      }


   }
   Fallback "Diffuse"
}

