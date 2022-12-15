Shader "Unlit/AfterImage"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _TrailDir;

            v2f vert (appdata v)
            {
                v2f o;
                fixed weight = saturate(dot(v.normal,_TrailDir));
                fixed noise = tex2Dlod(_NoiseTex, float4(v.uv.xy, 0, 0)).r;
                fixed4 trail = _TrailDir * weight * noise;
                v.vertex.xyz = float3(v.vertex.x + trail.x, v.vertex.y + trail.y, v.vertex.x + trail.z);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
