Shader "Unlit/ToonShading"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				//float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 halfVec = normalize(lightDir + viewDir);
				float NDotL = dot(i.worldNormal,lightDir);
				float NDotH = dot(i.worldNormal,halfVec);
				float3 diffuse = 1.0;
				diffuse = _LightColor0.rgb*col*(pow(NDotL*0.5+0.5,1.0));
				float3 specular = _LightColor0.rgb*1.0*pow(max(0,NDotH),20.0);
				// apply fog 8
				UNITY_APPLY_FOG(i.fogCoord, col);
				return float4(diffuse+specular,1.0);
			}
			ENDCG
		}
	}
}
