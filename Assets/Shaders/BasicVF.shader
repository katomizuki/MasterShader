Shader "Unlit/BasicVF"
{
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
            };

            struct v2f
            {
                float4 color : COLOR;
                float4 vertex : SV_POSITION;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // ｘ座標を赤にする
                //o.color.r = (v.vertex.x + 10) / 10;
                //o.color.g = (v.vertex.z + 10) / 10;
               // o.color.b = (v.vertex.y + 10) / 10;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = i.color;
                return col; 
            }
            ENDCG
        }
    }
}
