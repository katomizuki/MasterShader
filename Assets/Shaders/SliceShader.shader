Shader "Unlit/SliceShader"
{
    Properties
    {
        // ここに書いていたものがInspectorで表示される。
        _Color("MainColor", Color) = (0, 0, 0, 0)
        // スライスされる間隔
        _SliceSpace("SliceSpace", Range(0, 30)) = 15
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

            half4 _Color;
            half _SliceSpace;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                clip(frac(i.worldPos.y * _SliceSpace) - 0.5);
                
                // sample the texture
                return half4(_Color);
            }
            ENDCG
        }
    }
}
