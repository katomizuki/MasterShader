Shader "Unlit/outlineShader2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurColor("Blur Color",Color) = (1,1,1,1)
        _BlurSize("BlurSize", float) = 1
        _Speed("Speed", float) = 1
        _Angle("Angle",Range(0,1)) = 1
        _Offset("xy: offset, zw : notUsing",Vector) = (0.5,0.5,0,0)
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed4 _BlurColor;
            float _BlurSize;
            half _Speed;
            half _Angle;
            fixed4 _Offset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
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
