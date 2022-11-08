Shader "Unlit/yurayura"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { 
            "RenderType"="Geometry"
            "RenderType"="Opaque" 
            }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                // クリップ座標系に変換してから
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_UV(v.texcoord, _MainTex);
                float amp = 0.5 * sin(_Time * 100 + v.vertex.x * 100);
                o.vertex.xyz = float3(o.vertex.x , o.vertex.y + amp, o.vertex.z);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                return c;
            }
            ENDCG
        }
    }
}
