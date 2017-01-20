#ifndef VACUUMSHADERS_SSS_CGINC
#define VACUUMSHADERS_SSS_CGINC



//////////////////////////////////////////////////////////////////////////////
//                                                                          // 
//Defines                                                                   //                
//                                                                          //               
//////////////////////////////////////////////////////////////////////////////
#ifdef V_SSS_POW_ONE
#define V_SSS_POW(x) x;
#endif
#ifdef V_SSS_POW_TWO
#define V_SSS_POW(x) x = x * x;
#endif
#ifdef V_SSS_POW_FOUR
#define V_SSS_POW(x) x = x * x; x = x * x;
#endif
#ifdef V_SSS_POW_EIGHT
#define V_SSS_POW(x) x = x * x; x = x * x; x = x * x;
#endif
#ifdef V_SSS_POW_SIXTEEN
#define V_SSS_POW(x) x = x * x; x = x * x; x = x * x; x = x * x;
#endif

//////////////////////////////////////////////////////////////////////////////
//                                                                          // 
//Variables                                                                 //                
//                                                                          //               
//////////////////////////////////////////////////////////////////////////////
fixed4 _Color;
sampler2D _MainTex;

#ifdef V_SSS_VERTEXLIT
	float4 _MainTex_ST;
#endif

#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON
	sampler2D _TransMap;
	fixed4 _TransColor;
	half _TransBackfaceIntensity;
#endif

#ifdef V_SSS_TWO_TEXTURES
	sampler2D _LayerMask;
	sampler2D _SecondTex;
	sampler2D _SecondBump;
	float _MaskPower;
#endif

#if defined(V_SSS_TWO_TEXTURES) && defined(V_SSS_ADVANCED_TRANSLUSENCY_ON)
	sampler2D _SecondTransMap;
	fixed4 _SecondTransColor;
#endif

#ifdef V_SSS_BUMPED
	half _BumpSize;
	sampler2D _BumpMap;
#endif

#ifdef V_SSS_SPECULAR
	half _Shininess;
#endif

#ifdef V_SSS_REFLECTIVE
	fixed4 _ReflectColor;
	samplerCUBE _Cube;
#endif

half _TransDistortion;
half _TransPower;
half _TransScale;

half _TransDirectianalLightStrength;
half _TransOtherLightsStrength;
half _V_SSS_Emission;

#ifdef V_SSS_RIM_ON
	fixed4 _V_SSS_Rim_Color;
	fixed _V_SSS_Rim_Pow;
#endif

//////////////////////////////////////////////////////////////////////////////
//                                                                          // 
//Structs                                                                   //                
//                                                                          //               
//////////////////////////////////////////////////////////////////////////////
#ifdef V_SSS_VERTEXLIT
	struct v2f_surf 
	{
		half4 pos : SV_POSITION;
		half2 uv : TEXCOORD0;				

		#ifndef LIGHTMAP_OFF
			float2 lmap : TEXCOORD1;
		#else
			fixed3 vlight : TEXCOORD1;
		#endif
		
		#ifdef V_SSS_RIM_ON
			fixed3 rim : TEXCOORD2;
		#endif
	};
#endif

struct TransSurfaceOutput
{
	fixed3 Albedo;
	fixed3 Normal;
	fixed3 Emission;
	half Specular;
	fixed Gloss;
	fixed Alpha;
	fixed3 TransCol;
};

struct Input
{
	float2 uv_MainTex;

	#ifdef V_SSS_RIM_ON
		 float3 viewDir;
	#endif

	#ifdef V_SSS_BUMPED
		float2 uv_BumpMap;
	#endif

	#ifdef V_SSS_REFLECTIVE
		float3 worldRefl;
	#endif

	#if defined(V_SSS_BUMPED) && defined(V_SSS_REFLECTIVE)
		INTERNAL_DATA
	#endif

	#ifdef V_SSS_TWO_TEXTURES
		float3 worldPos;
		float2 uv_SecondTex;
		float2 uv_SecondBump;
	#endif
};

//////////////////////////////////////////////////////////////////////////////
//                                                                          // 
//Functions                                                                  //                
//                                                                          //               
//////////////////////////////////////////////////////////////////////////////
#ifdef V_SSS_VERTEXLIT
inline half3 V_Shade4PointLights ( half4 lightPosX, half4 lightPosY, half4 lightPosZ,
								   half3 lightColor0, half3 lightColor1, half3 lightColor2, half3 lightColor3,
								   half4 lightAttenSq,
								   half3 pos, half3 normal, half3 viewDir)
{
	// to light vectors
	half4 toLightX = lightPosX - pos.x;
	half4 toLightY = lightPosY - pos.y;
	half4 toLightZ = lightPosZ - pos.z;
	// squared lengths
	half4 lengthSq = 0;
	lengthSq += toLightX * toLightX;
	lengthSq += toLightY * toLightY;
	lengthSq += toLightZ * toLightZ;
	// NdotL
	half4 ndotl = 0;
	ndotl += toLightX * normal.x;
	ndotl += toLightY * normal.y;
	ndotl += toLightZ * normal.z;
	// correct NdotL
	half4 corr = rsqrt(lengthSq);
	ndotl = ndotl * corr;
	#ifdef V_SSS_NORMALIZE_DIFFUSE_COEF_ON
		ndotl = max(half4(0,0,0,0), ndotl);
	#endif

	// attenuation
	half4 atten = 1.0 / (1.0 + lengthSq * lightAttenSq);
		
	half3 diffCol = 0;
	half3 distortionNormal = normal * _TransDistortion;

	
	#ifdef V_SSS_LIGHTCOUNT_ONE
		half3 transLight0 = normalize(half3(toLightX[0], toLightY[0], toLightZ[0])) + distortionNormal;
		
		half transDot0 = saturate(dot(viewDir, -transLight0));
		V_SSS_POW(transDot0)

		lightColor0 *= 2;
		#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON
			half3 lightAtten = lightColor0 * atten[0] * _TransOtherLightsStrength;
			half3 transComponent = lerp(transDot0 + _Color.rgb, _TransColor * _TransScale, transDot0);	
			transComponent += (1 - ndotl[0]) * _TransColor * lightColor0 * _TransBackfaceIntensity * 0.5;

			diffCol += lightColor0 * atten[0] * ndotl[0] + lightAtten * transComponent;
		#else
			diffCol += lightColor0 * atten[0] * ((transDot0 * _TransScale + _Color.rgb) * _TransOtherLightsStrength + ndotl[0]);
		#endif
	#endif

	#ifdef V_SSS_LIGHTCOUNT_TWO
		half3 transLight1 = normalize(half3(toLightX[1], toLightY[1], toLightZ[1])) + distortionNormal;
		
		half transDot1 = saturate(dot(viewDir, -transLight1));
		V_SSS_POW(transDot1)

		lightColor1 *= 2;
		#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON			 
			lightAtten = lightColor1 * atten[1] * _TransOtherLightsStrength;
			transComponent = lerp(transDot1 + _Color.rgb, _TransColor * _TransScale, transDot1);	
			transComponent += (1 - ndotl[1]) * _TransColor * lightColor1 * _TransBackfaceIntensity * 0.5;

			diffCol += lightColor1 * atten[1] * ndotl[1] + lightAtten * transComponent;
		#else
			diffCol += lightColor1 * atten[1] * ((transDot1 * _TransScale + _Color.rgb) * _TransOtherLightsStrength + ndotl[1]);
		#endif
	#endif

	#ifdef V_SSS_LIGHTCOUNT_THREE
		half3 transLight2 = normalize(half3(toLightX[2], toLightY[2], toLightZ[2])) + distortionNormal;
		
		half transDot2 = saturate(dot(viewDir, -transLight2));
		V_SSS_POW(transDot2)

		lightColor2 *= 2;
		#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON			 
			lightAtten = lightColor2 * atten[2] * _TransOtherLightsStrength;
			transComponent = lerp(transDot2 + _Color.rgb, _TransColor * _TransScale, transDot2);	
			transComponent += (1 - ndotl[2]) * _TransColor * lightColor2 * _TransBackfaceIntensity * 0.5;

			diffCol += lightColor2 * atten[2] * ndotl[2] + lightAtten * transComponent;
		#else
			diffCol += lightColor2 * atten[2] * ((transDot2 * _TransScale+ _Color.rgb) * _TransOtherLightsStrength + ndotl[2]);
		#endif
	#endif

	#ifdef V_SSS_LIGHTCOUNT_FOUR
		half3 transLight3 = normalize(half3(toLightX[3], toLightY[3], toLightZ[3])) + distortionNormal;
		
		half transDot3 = saturate(dot(viewDir, -transLight3));
		V_SSS_POW(transDot3)

		lightColor3 *= 2;
		#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON			 
			lightAtten = lightColor3 * atten[3] * _TransOtherLightsStrength;
			transComponent = lerp(transDot3 + _Color.rgb, _TransColor * _TransScale, transDot3);	
			transComponent += (1 - ndotl[3]) * _TransColor * lightColor3 * _TransBackfaceIntensity * 0.5;

			diffCol += lightColor3 * atten[3] * ndotl[3] + lightAtten * transComponent;
		#else
			diffCol += lightColor3 * atten[3] * ((transDot3 * _TransScale + _Color.rgb) * _TransOtherLightsStrength + ndotl[3]);
		#endif
	#endif

	return diffCol;
}
#endif


//////////////////////////////////////////////////////////////////////////////
//                                                                          // 
//Lighting                                                                  //                
//                                                                          //               
//////////////////////////////////////////////////////////////////////////////
inline fixed4 LightingTransBlinnPhong (TransSurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
{	
	half atten2 = (atten * 2);

	fixed3 diffCol;
	fixed3 specCol;
	float spec;	
	
	half NL = dot (s.Normal, lightDir);
	#ifdef V_SSS_NORMALIZE_DIFFUSE_COEF_ON
		NL = max(0.0, NL);
	#endif

	half3 h = normalize (lightDir + viewDir);
	
	float nh = max (0, dot (s.Normal, h));
	spec = pow (nh, s.Specular*128.0) * s.Gloss;
	
	diffCol = (s.Albedo * _LightColor0.rgb * NL) * atten2;
	specCol = (_LightColor0.rgb * _SpecColor.rgb * spec) * atten2;

	half3 transLight = lightDir + s.Normal * _TransDistortion;
	float VinvL = saturate(dot(viewDir, -transLight));
	
	float transDot = pow(VinvL,_TransPower);
	#ifndef V_SSS_ADVANCED_TRANSLUSENCY_ON
		transDot *= _TransScale;
	#endif 

	half3 lightAtten = _LightColor0.rgb * atten2;
	#ifdef UNITY_PASS_FORWARDBASE
		lightAtten *= _TransDirectianalLightStrength;
	#else
		lightAtten *= _TransOtherLightsStrength;
	#endif

	half3 transComponent = (transDot + _Color.rgb);
	#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON	
		half3 subSurfaceComponent = s.TransCol * _TransScale;	
		transComponent = lerp(transComponent, subSurfaceComponent, transDot);		

		transComponent += (1 - NL) * s.TransCol * _LightColor0.rgb * _TransBackfaceIntensity;
	#endif

	diffCol = s.Albedo * (_LightColor0.rgb * atten2 * NL + lightAtten * transComponent);

	
	fixed4 c;
	c.rgb = diffCol + specCol * 2;
	c.a = s.Alpha + _LightColor0.a * _SpecColor.a * spec * atten;
	return c;
}

inline fixed4 LightingTransPhong (TransSurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
{	
	half atten2 = (atten * 2);

	fixed3 diffCol = fixed3(0, 0, 0);
	
	half NL = dot(s.Normal, lightDir);
	#ifdef V_SSS_NORMALIZE_DIFFUSE_COEF_ON
		NL = max(0.0, NL);
	#endif
	
	half3 transLight = lightDir + s.Normal * _TransDistortion;
	float VinvL = saturate(dot(viewDir, -transLight));

	float transDot = pow(VinvL,_TransPower);
	#ifndef V_SSS_ADVANCED_TRANSLUSENCY_ON
		transDot *= _TransScale;
	#endif 
	
	half3 lightAtten = _LightColor0.rgb * atten2;
	#ifdef UNITY_PASS_FORWARDBASE
		lightAtten *= _TransDirectianalLightStrength;
	#else
		lightAtten *= _TransOtherLightsStrength;
	#endif

	half3 transComponent = (transDot + _Color.rgb);
	#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON	
		half3 subSurfaceComponent = s.TransCol * _TransScale;	
		transComponent = lerp(transComponent, subSurfaceComponent, transDot);		

		transComponent += (1 - NL) * s.TransCol * _LightColor0.rgb * _TransBackfaceIntensity;
	#endif	

	diffCol = s.Albedo * (_LightColor0.rgb * atten2 * NL + lightAtten * transComponent);
	
	fixed4 c; 
	c.rgb = diffCol;
	c.a = s.Alpha + _LightColor0.a * atten;
	return c;
}

void surf (Input IN, inout TransSurfaceOutput o)
{
	half4 tex = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = tex.rgb * _Color.rgb;
	o.Alpha = tex.a * _Color.a;

	#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON
		o.TransCol = tex2D(_TransMap,IN.uv_MainTex).rgb * _TransColor.rgb;
	#endif

	#ifdef V_SSS_SPECULAR
		o.Gloss = tex.a;
		o.Specular = _Shininess;
	#endif

	#ifdef V_SSS_BUMPED
		o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		o.Normal.x *= _BumpSize;
		o.Normal.y *= _BumpSize;
		o.Normal = normalize(o.Normal);
	#endif

	#ifdef V_SSS_REFLECTIVE
		#ifdef V_SSS_BUMPED
			float3 worldRefl = WorldReflectionVector (IN, o.Normal);
			fixed4 reflcol = texCUBE (_Cube, worldRefl);
		#else
			fixed4 reflcol = texCUBE (_Cube, IN.worldRefl);
		#endif

		reflcol *= tex.a;
		o.Emission = reflcol.rgb * _ReflectColor.rgb;
	#endif

	
	o.Emission += o.Albedo * _V_SSS_Emission * o.Alpha;


	#ifdef V_SSS_RIM_ON
		half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
        o.Emission += _V_SSS_Rim_Color.rgb * pow (rim, _V_SSS_Rim_Pow);
	#endif
}


#ifdef V_SSS_VERTEXLIT
v2f_surf vert(appdata_full v) 
{
	v2f_surf o;
	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);

	half3 worldN = mul((half3x3)_Object2World, SCALED_NORMAL);
 
	#ifdef LIGHTMAP_OFF
		#ifndef V_SSS_AMBIENT_ON
			o.vlight = 0;
		#else
			o.vlight = UNITY_LIGHTMODEL_AMBIENT.rgb;
		#endif

		half3 viewDir = normalize(WorldSpaceViewDir( v.vertex ));
				

		//Directional Light
		#ifdef USING_DIRECTIONAL_LIGHT

			half NL = dot(worldN, _WorldSpaceLightPos0.xyz);
			#ifdef V_SSS_NORMALIZE_DIFFUSE_COEF_ON
				NL = max(0.0, NL);
			#endif
			
			half3 transLight_Dir = _WorldSpaceLightPos0.xyz + (worldN * _TransDistortion);
			half transDot_Dir = saturate(dot(viewDir, -transLight_Dir));
			V_SSS_POW(transDot_Dir)

			#ifdef V_SSS_ADVANCED_TRANSLUSENCY_ON
				
				half3 lightAtten = _LightColor0.rgb * _TransDirectianalLightStrength;
				half3 transComponent = lerp(transDot_Dir + _Color.rgb, _TransColor * _TransScale, transDot_Dir);	
				transComponent += (1 - NL) * _TransColor * _LightColor0.rgb * _TransBackfaceIntensity;

				o.vlight += _LightColor0.rgb * NL * 2 + lightAtten * transComponent * 2;
			#else
				o.vlight += (_LightColor0.rgb * ((transDot_Dir * _TransScale + _Color.rgb) * _TransDirectianalLightStrength + max(0, dot(worldN, _WorldSpaceLightPos0.xyz)))) * 2;
			#endif
		#endif
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


		#ifdef VERTEXLIGHT_ON
			half3 worldPos = mul(_Object2World, v.vertex).xyz;
	 
			
			o.vlight += V_Shade4PointLights (unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
											 unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
											 unity_4LightAtten0, worldPos, worldN, viewDir );			
		#endif
	#endif //LIGHTMAP_OFF

	#ifndef LIGHTMAP_OFF
		o.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
    #endif

	#ifdef V_SSS_RIM_ON
		half3 objSpaceCameraPos = mul(_World2Object, half4(_WorldSpaceCameraPos.xyz, 1)).xyz;
				
		half rim = 1.0 - saturate(dot (normalize(objSpaceCameraPos - v.vertex.xyz), v.normal));
		o.rim = _V_SSS_Rim_Color.rgb * rim * rim;
	#endif

    return o;
}


fixed4 frag (v2f_surf IN) : SV_Target 
{
	half4 albedo = tex2D(_MainTex, IN.uv.xy) * _Color;

	fixed4 retColor = albedo;
	#ifndef LIGHTMAP_OFF		
		retColor.rgb *= DecodeLightmap (UNITY_SAMPLE_TEX2D(unity_Lightmap, IN.lmap.xy));
	#else
		retColor.rgb *= IN.vlight;
	#endif

	retColor.rgb += albedo.rgb * _V_SSS_Emission * albedo.a; 

	#ifdef V_SSS_RIM_ON
		retColor.rgb += IN.rim; 
	#endif

	return retColor;
}
#endif

#endif	//cginc