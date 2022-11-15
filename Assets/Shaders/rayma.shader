Shader "Unlit/rayma"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius("Radius", Range(0.0, 1.0)) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "LightMode"="ForwardBase"}
        LOD 100

        Pass
        {
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : POSITION1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Radius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float sphere(float3 pos)
            {
                return length(pos) -_Radius;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 pos = i.pos.xyz;
                float3 rayDir = normalize(pos.xyz - _WorldSpaceCameraPos);
                // 処理を30回までとする
                int stepNum = 30;
                for (int i = 0; i < stepNum; i++)
                {
                    float marcingDist = sphere(pos);
                    if (marcingDist < 0.0001)
                    {
                        return 1.0;
                    }
                    pos.xyz += marcingDist * rayDir.xyz;
                }
                // どこにも衝突しない場合
                return 0;
            }
            ENDCG
        }
    }
}
