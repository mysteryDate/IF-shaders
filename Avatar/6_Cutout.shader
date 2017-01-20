Shader "Aaron/Avatar/6_Cutout" {
   Properties {
   	  _IFPos ("IF Position", Vector) = (0,0,0,0)
   	  _AvatarPos ("Avatar Position", Vector) = (0,0,0,0)
   	  _AvatarRotation ("Avatar Rotation", Vector) = (0,0,0,0)
      _MainTex ("Color (RGB) Alpha (A)", 2D) = "black" {}
      _BackTex ("Back Texture", 2D) = "BlueSpace" {}
      _BumpTex ("Bumpmap", 2D) = "bump" {}
      _AlphaMask ("Alpha Mask", 2D) = "white" {}
      _FrontColor ("Front Color", Color) = (0, 0, 0.24, 0.0)
      _RimColor("Rim Color", Color) = (0.0,0.75,1.0,0.0)
      _RimPower ("Rim Power", Range(0.1,8)) = 0.5
      _RimAlpha ("Rim Opacity", Range(0,0.5)) = 0.3
      _SpotRadius ("Spot Radius", Range(0, 10)) = 2 
      _SpotPower ("Spot Power", Range(0, 100)) = 5
      _BumpDepth ("BumpDepth", Range(0.2,3.0)) = 2.2
      _IVSpotRadius ("Inner View Spot Raidus", Range(0, 1)) = 0.7
      _IVSpotPower ("Inner View Spot Power", Range(0, 100)) = 7
      _IVRimAlpha ("IV Rim Opacity", Range(0,1)) = 0.08
	  _TextureShift ("Texture Shift", Vector) = (0.54,0.7,0,0)
	  _TextureScale ("Texture Scale", Vector) = (8.55,27.53,0,0)
	  _BaseAlpha ("Minimum Alpha", Range(0,1)) = 0.2
	  _AlphaCutoff ("Alpha Cutoff", Range(0,3)) = 0
      [MaterialToggle] _IsInner("Inner View", Float) = 0
      
   }
   SubShader {
      Tags { "Queue" = "Transparent" "RenderType" = "Transparent" } 
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
         float4x4 _AvatarViewMatrix;
         float4x4 _AvatarProjectionMatrix;
         float4x4 _AvatarModelMatrix;
         float _BumpDepth;
         float4 _TextureShift;
         float4 _TextureScale;
         float4 _RimColor;
         float _RimPower;
         float _AlphaCutoff;
         

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

			
            float4 tex = tex2D(_BackTex, (i.viewPos.xy / _TextureScale.xy) + _TextureShift.xy);
            float4 finalColor = tex + _RimColor * pow(rim, -_RimPower);
            
            float4 maskTex = tex2D(_AlphaMask, i.tex.xy);
            float al = maskTex.b / _AlphaCutoff;
            
            return float4(tex.rgb, al);
         } 
 
         ENDCG  
      }
 
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
         uniform sampler2D _BumpTex;
         uniform sampler2D _AlphaMask;
         float4 _FrontColor;
         float4 _RimColor;
         float4 _IFPos;
         float _SpotRadius;
         float _SpotPower;
         float _RimPower;
         float _BumpDepth;
         float _RimAlpha;
         float _IVSpotPower;
         float _IVSpotRadius;
         float _IVRimAlpha;
         float _IsInner;
         float _BaseAlpha;
         float _AlphaCutoff;

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
            float3 closestPoint: TEXCOORD5;
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
            return o;
         }


         // Fragment function
         float4 frag(vertexOutput i) : COLOR 
         {
         	float spotRadius = _SpotRadius;
         	float spotPower = _SpotPower;
         	float rimAlpha = _RimAlpha;
         	if(_IsInner == 1) {
         		spotRadius = _IVSpotRadius;
         		spotPower = _IVSpotPower;
         		rimAlpha = _IVRimAlpha;
         		_BaseAlpha = 0;
         	}
            float4 texN = tex2D(_BumpTex, i.tex.xy);
            float3 localCoords = float3(2.0 * texN.ag - float2(1.0,1.0), 0.0);
            localCoords.z = _BumpDepth;

            float3x3 local2WorldTranspose = float3x3(
               i.tangentDir,
               i.binormalDir,
               i.normalDir);

            float3 normalDirection = normalize( mul(localCoords, local2WorldTranspose));

            float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);

            float rim = (1 - dot(normalize(viewDirection), normalDirection));
            
            float4 cameraPos = float4(_WorldSpaceCameraPos.xyz, 1.0);
            
            // This is the distance from the fragment to the closest point on the line between the camera and the inner friend
            float dist = length( cross(i.posWorld.xyz - _IFPos.xyz, i.posWorld.xyz - cameraPos.xyz) ) / length (cameraPos - i.posWorld);
            
            float al = pow((pow(dist / spotRadius, spotPower)) * (rim * rimAlpha), 0.5);

            float4 finalColor = _FrontColor + _RimColor * pow(rim, _RimPower);
            
            float4 maskTex = tex2D(_AlphaMask, i.tex.xy);
            
            al = maskTex.r;

            return float4(finalColor.rgb, al);
         } 
         ENDCG  
      }
   }
   Fallback "Diffuse"
}
