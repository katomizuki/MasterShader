Shader "OpaqueStencilMask"  
{
    Properties  
    {
        _MainTex("Texture", 2D) = "white"{}  
    }

    SubShader  
    {
        Tags {"Queue"="Geometry"}  
        Pass  
        {
            Stencil {  
                Ref 2  
                // ステンシルを絶対通るようにする
                Comp always  
                // 2というステンシルバッファを書き込む
                Pass replace  
            }
            CGPROGRAM  
            sampler2D _MainTex;  
            #pragma vertex vert_img  
            #pragma fragment frag  
            #include "UnityCG.cginc"  

            fixed4 frag (v2f_img i) : SV_Target  
            {
                fixed4 c = tex2D(_MainTex, i.uv);  
                return c;  
            }
            ENDCG  
        }
    }
}