Shader "particle" 
{
	// Bound with the inspector.
 	Properties 
 	{
        _Color ("Main Color", Color) = (0, 1, 1,1)
        _SpeedColor ("Speed Color", Color) = (1, 0, 0, 1)
        _colorSwitch ("Switch", Range (0, 5)) = 0.5
    }

	SubShader 
	{
		Tags {  "Queue" = "Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Pass 
		{
			
			Zwrite On
			Ztest Always

			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			// The same particle data structure used by both the compute shader and the shader.
			struct Particle
			{
				float3 position;
				float3 velocity;
			};
			
			// structure linking the data between the vertex and the fragment shader
			struct FragInput
			{
				float4 color : COLOR;
				float4 position : SV_POSITION;
			};
			
			// The buffer holding the particles shared with the compute shader.
			StructuredBuffer<Particle> particleBuffer;
			
			
			// Variables from the properties.
			float4 _Color;
			float4 _SpeedColor;
			float _colorSwitch;
			
			// DX11 vertex shader these 2 parameters come from the draw call: "1" and "particleCount", 
			// SV_VertexID: "1" is the number of vertex to draw peer particle, we could easily make quad or sphere particles with this.
			// SV_InstanceID: "particleCount", number of particles...
			FragInput vert (uint id : SV_VertexID, uint inst : SV_InstanceID)
			{
				FragInput fragInput;
				
				// color computation
//				float speed = length(particleBuffer[inst].velocity);
//				float lerpValue = clamp(speed / _colorSwitch, 0, 1);
//				fragInput.color = lerp(_Color, _SpeedColor, lerpValue);
				float i = length(particleBuffer[inst].velocity.x)/7;
				float4 c;
				c.r = saturate(abs(6 * i - 3) - 1);
                c.g = saturate(-abs(6 * i - 2) + 2);
                c.b = saturate(-abs(6 * i - 4) + 2);
                fragInput.color = c;
				
				// position computation
				fragInput.position = mul (UNITY_MATRIX_MVP, float4(particleBuffer[inst].position, 1));
				
				return fragInput;
			}
			
			// this just pass through the color computed in the vertex program
			float4 frag (FragInput fragInput) : COLOR
			{
				return fragInput.color;
			}
			
			ENDCG
		
		}
	}

	Fallback Off
}
