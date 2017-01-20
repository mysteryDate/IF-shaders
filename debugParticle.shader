// For drawing GPGPU generated paricles (like for the super collider)
Shader "Aaron/DebugParticle" 
{

	SubShader 
	{
		Pass 
		{
			Blend SrcAlpha one
			Ztest always

			CGPROGRAM
			#pragma target 5.0
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			// The same particle data structure used by both the compute shader and the shader.
			struct Particle
			{
				float3 position;
				float3 color;
			};
			
			// structure linking the data between the vertex and the fragment shader
			struct FragInput
			{
				float4 color : COLOR;
				float4 position : SV_POSITION;
			};
			
			// The buffer holding the particles shared with the compute shader.
			StructuredBuffer<Particle> particleBuffer;
			
			// DX11: The vertex shader gets the 2 parameters come from the draw call: "particleCount" and "1", 
			// SV_VertexID: "1" is the number of vertex to draw per particle, we could easily make quad or sphere particles with this.
			// SV_InstanceID: "particleCount", number of particles...
			FragInput vert (uint id : SV_VertexID, uint inst : SV_InstanceID)
			{
				FragInput fragInput;
				
				// position computation
				fragInput.position = mul(UNITY_MATRIX_VP,  float4(particleBuffer[inst].position ,1));
				fragInput.color = float4(particleBuffer[inst].color, 1);
				
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
