// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/wave"
{
	Properties
	{ 
		_MainTex ("Texture", 2D) = "white" {}
		_MainColor("MainColor",Color) = (0,0,1,1)
		_waveLength("_waveLength",float) = 1.0
		_steepness("_steepness",Range(0,1.0)) =0.6
		_direction("_direction 2d",vector) = (1,0,0,0)
		_amplitude("_amplitude",float) = 1.0
		_LineLength("LineLength",float) = 0.03
        _LineColor("LineColor",COLOR) = (1,0,0,1)
	}
	SubShader
	{

		Pass
		{
					Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 tangent : TEXCOORD1;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _waveLength;
			float _steepness;
			vector _direction;
			float4 _MainColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				
				float3 p =v.vertex.xyz;
				float k = 2*UNITY_PI/_waveLength;
				float a = _steepness/k;
				float c = sqrt(9.8/k);
				float2 d = normalize(_direction);
				float f = k*(dot(d,p.xz)-c*_Time.y);
				p.x += d.x*a*cos(f);
				p.y = a*sin(f);
				p.z += d.y*a*cos(f);
				float3 tangent = float3(1-d.x*d.x*_steepness*sin(f),d.x*_steepness*cos(f),-d.x*d.y*_steepness*sin(f));
				float3 binormal = float3(-d.x*d.y*_steepness*sin(f),d.y*_steepness*cos(f),1-d.y*d.y*_steepness*sin(f));
				v.normal =  cross(binormal,tangent);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));	
				o.vertex = UnityObjectToClipPos(float4(p.xyz,1));
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				o.uv = v.uv;
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				float3 worldNormal = normalize(i.worldNormal);
				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				float3 diffuse = _LightColor0*_MainColor.rgb*max(0,dot(worldNormal,worldLightDir));
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
				float3 halfVec = normalize(viewDir + worldLightDir);
				float3 specular = _LightColor0*pow(max(0,dot(worldNormal,halfVec)),20.0);

				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return float4(diffuse+specular,1.0);
			}
			ENDCG
		}
		Pass
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200
 
            CGPROGRAM
                #pragma target 5.0
                #pragma vertex VS_Main
                #pragma fragment FS_Main
                #pragma geometry GS_Main
                #include "UnityCG.cginc"
 
                float _LineLength;
                fixed4 _LineColor;
				float _waveLength;
			float _steepness;
			vector _direction;
                 
 
                struct GS_INPUT
                {
                    float4    pos       : POSITION;
                    float3    normal    : NORMAL;
                    float2  tex0        : TEXCOORD0;
                };
                struct FS_INPUT
                {
                    float4    pos       : POSITION;
                    float2  tex0        : TEXCOORD0;
                };
                //step1
                GS_INPUT VS_Main(appdata_base v)
                {
					float3 p =v.vertex.xyz;
				float k = 2*UNITY_PI/_waveLength;
				float a = _steepness/k;
				float c = sqrt(9.8/k);
				float2 d = normalize(_direction);
				float f = k*(dot(d,p.xz)-c*_Time.y);
				p.x += d.x*a*cos(f);
				p.y = a*sin(f);
				p.z += d.y*a*cos(f);
				float3 tangent = float3(1-d.x*d.x*_steepness*sin(f),d.x*_steepness*cos(f),-d.x*d.y*_steepness*sin(f));
				float3 binormal = float3(-d.x*d.y*_steepness*sin(f),d.y*_steepness*cos(f),1-d.y*d.y*_steepness*sin(f));
				v.normal =  cross(binormal,tangent);
				v.vertex.xyz = p.xyz;
                    GS_INPUT output = (GS_INPUT)0;
                    output.pos = mul(unity_ObjectToWorld, v.vertex);
                    //output.pos = UnityObjectToClipPos(v.vertex);
                    output.normal = v.normal;
                    //float4 viewNormal = mul(UNITY_MATRIX_IT_MV, float4(v.normal, 0));
                    float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                    output.normal = normalize(worldNormal);
                    output.tex0 = float2(0, 0);
                    return output;
                }
                [maxvertexcount(4)]
                void GS_Main(point GS_INPUT p[1], inout LineStream<FS_INPUT> triStream)
                {
                    FS_INPUT pIn;
                    pIn.pos =mul(UNITY_MATRIX_VP, p[0].pos);// UnityObjectToClipPos(p[0].pos);
                    pIn.tex0 = float2(0.0f, 0.0f);
                    triStream.Append(pIn);
                    FS_INPUT pIn1;
                    float4 pos= p[0].pos + float4(p[0].normal,0) *_LineLength;
                    pIn1.pos = mul(UNITY_MATRIX_VP, pos);
                    pIn1.tex0 = float2(0.0f, 0.0f);
                    triStream.Append(pIn1);
 
                }
 
                //step3
                fixed4 FS_Main(FS_INPUT input) : COLOR
                {
                    return _LineColor;
                }
            ENDCG
        }
	}
}
