Shader "Aaron/Avatar/7back_ContainedParticles" {
   Properties {
      _BackTex ("Back Texture", 2D) = "BlueSpace" {}
      _BumpTex ("Bumpmap", 2D) = "bump" {}
      _RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
      _RimPower ("Rim Power", Range(0.1,8)) = 0.5
      _BumpDepth ("BumpDepth", Range(0.2,3.0)) = 2.2
	  _TextureShift ("Texture Shift", Vector) = (0.54,0.7,0,0)
	  _TextureScale ("Texture Scale", Vector) = (8.55,27.53,0,0)
	  [MaterialToggle] _UseUV ("Use UV Map", Float) = 0
      
   }
   SubShader {
      Tags { "Queue" = "Geometry"} 
      Pass {
      	
         Cull Front // first pass renders only back faces
         ZWrite On // write to the depth buffer, since this side is opaque
 
         CGPROGRAM 
 
         #pragma vertex vert 
         #pragma fragment frag
 
         // Variables
         uniform sampler2D _BackTex;
         uniform sampler2D _BumpTex;
         float4x4 _AvatarViewMatrix;
         float4x4 _AvatarProjectionMatrix;
         float4x4 _AvatarModelMatrix;
         float _BumpDepth;
         float4 _TextureShift;
         float4 _TextureScale;
         float4 _RimColor;
         float _RimPower;
         float _UseUV;
         

         //base input structs
         struct vertexInput {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
            float4 tangent : TANGENT;
         };
         struct vertexOutput {
            float4 pos : SV_POSITION;
            float4 posWorld : TEXCOORD0;
            float3 normalDir : TEXCOORD1;
            float4 tex : TEXCOORD2;
            float3 tangentDir : TEXCOORD3;
            float3 binormalDir: TEXCOORD4;
            float4 viewPos : TEXCOORD5;
         };

         // vertex function
         vertexOutput vert(vertexInput v){
            vertexOutput o;
            
            o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
            o.tangentDir = normalize( mul( _Object2World, float4(v.tangent.xyz, 0.0)).xyz);
            o.binormalDir = normalize( cross(o.normalDir, o.tangentDir) * v.tangent.w);
            
            o.posWorld = mul(_Object2World, v.vertex);
            o.tex = v.texcoord;
            o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
            float4x4 finalMatrix = mul(mul(_AvatarProjectionMatrix, _AvatarViewMatrix), _Object2World);
            o.viewPos = mul(finalMatrix, v.vertex);
            return o;
         }


         // Fragment function
         float4 frag(vertexOutput i) : COLOR 
         {
            float4 texN = tex2D(_BumpTex, i.tex.xy);
            // Unity stores textures in [0,1] on alpha and green
            // This converts to [-1,1] on red and green (0 for blue)
            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
			localCoords.z = _BumpDepth;

            float3x3 local2WorldTranspose = float3x3(
               i.tangentDir,
               i.binormalDir,
               i.normalDir);

            float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));
            //float3 normalDirection = i.normalDir;
            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
            float rim = (1 - dot(normalize(viewDirection), normalDirection));

			float2 newPos = (i.viewPos.xy + _TextureShift.xy) / _TextureScale.xy;
			
			if(_UseUV == 1) {
				newPos = i.tex.xy + float2(0.13, -0.08);
			}

            float4 tex = tex2D(_BackTex, newPos);
            float4 finalColor = tex + _RimColor * pow(rim, -_RimPower);
            
//            float4 maskTex = tex2D(_AlphaMask, i.tex.xy);
//            float al = maskTex.b / _AlphaCutoff;
//            if(newPos.x > 1 || newPos.x < 0 || newPos.y > 1 || newPos.y < 0) {
//				tex.rgb = (1,1,1);
//			}
            return float4(tex.rgb, 1);
         } 
 
         ENDCG  
      }
 		Pass {
 		// This pass will write the front side to the zbuffer to contain particles
 			Cull Back
 			ZWrite On
 			ColorMask 0
 		
 		}
   }
   Fallback "Diffuse"
}
