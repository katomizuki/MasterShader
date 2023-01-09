Shader "Unlit/FrontFaces"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScalarVal("Value", Range(0.0, 1.0)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                fixed val : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _ScalarVal;

            v2f vert (appdata_base v)
            {
                v2f o;
                float4 world_pos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                const float3 world_normal = normalize(UnityObjectToWorldNormal(v.normal));
                const float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - world_pos.xyz);
                // 法線と視線方向の内積をとりそれをvalと比べることで後ろから消えるようになる。
                if(dot(world_normal, viewDir)  > _ScalarVal)
                    o.val = 1;
                else
                    o.val = 0;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if(i.val < 0.99) discard;
                const fixed col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
