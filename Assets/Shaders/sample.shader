Shader "Unlit/sample"
{
    Properties
    {
        _Color1("color1", Color) = (0, 0, 0, 0)
        _Color2("color2", Color) = (1, 1, 1, 1)
    }
    SubShader
    {

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float3 worldPos : WORLD_POS;
                float4 vertex : SV_POSITION;
            };

            float4 _Color1;
            float4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return  o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float interpolation = dot(normalize(i.worldPos), float2(0, 1));
                fixed4 color = lerp( _Color1, _Color2, interpolation);
                return color;
            }
            ENDCG
        }
    }
}
